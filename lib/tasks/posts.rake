namespace :posts do
  desc 'Convert categories'
  task categories: :environment do
    puts 'Converting categories'
    Category.all.each do |cat|
      cat.uuid = SecureRandom.hex.to_s[0..7]
      cat.save
    end
  end

  desc 'Convert discussions/revisions/replies into posts'
  task discussions: :environment do
    puts 'Converting discussions'
    ActiveRecord::Base.record_timestamps = false

    Discussion.all.order('created_at DESC').each do |discussion|
      existing = Post.select(:id, :uuid).where(:uuid => discussion.uuid).first

      if existing && existing.versions.size != discussion.revisions.size
        puts "Deleting outdated post #{existing.uuid}"
        existing.destroy
      end

      post = nil
      discussion.revisions.reverse.each do |revision|
        if post == nil
          post = Post.new
          post.author_id = revision.user_id
        end

        post.name = revision.title
        post.body = revision.body[0..60000]
        post.stickied = revision.stickied
        post.deleted = revision.archived
        post.archived = !post.stickied? && (Time.now -  revision.created_at) > 1.month
        post.locked = revision.locked
        post.created_at = discussion.created_at
        post.updated_at = revision.created_at
        post.category_id = revision.category_id
        post.uuid = discussion.uuid
        PaperTrail.whodunnit = revision.user_id

        if post.category.nil?
          puts 'BAD CATEGORY: ' + post.to_json
        end

        begin
          post.save(:validate => false)
        rescue Exception => e
          puts e
          puts e.backtrace
          next
        end

        version = post.versions.last
        version.created_at = revision.created_at
        version.save

      end
    end
  end

  desc 'Convert replies into posts'
  task replies: :environment do
    puts 'Converting replies'
    ActiveRecord::Base.record_timestamps = false

    Reply.all.order('created_at DESC').each do |reply|
      existing = Post.select(:id).where(:uuid => reply.id.to_s.each_byte.map { |b| b.to_s(16) }.join[0..7]).first

      if existing && existing.versions.size != reply.revisions.size
        puts "Deleting outdated post #{existing.uuid}"
        existing.destroy
      end

      post = nil
      reply.revisions.reverse.each do |revision|
        if post == nil
          post = Post.new
          post.author_id = revision.user_id
          post.parent_id = Post.find_by_uuid(reply.discussion.uuid).id if reply.discussion
          post.ancestor_id = Post.find_by_uuid(reply.reply_id.to_s.each_byte.map { |b| b.to_s(16) }.join[0..7]).id if reply.reply_id

          if post.parent.nil?
            puts "BAD PARENT: #{reply.discussion.to_json}"
            break
          elsif reply.reply_id && post.ancestor_id.nil?
            puts "BAD ANCESTOR: #{reply.to_json}"
            break
          end

          post.parent.last_reply_at = reply.created_at
        end

        post.name = revision.title
        post.body = revision.body[0..60000]
        post.deleted = revision.archived
        post.archived = false
        post.created_at = reply.created_at
        post.updated_at = revision.created_at
        post.category_id = revision.category_id
        post.uuid = reply.id.to_s.each_byte.map { |b| b.to_s(16) }.join[0..7]
        PaperTrail.whodunnit = revision.user_id

        if post.category.nil?
          puts 'BAD CATEGORY: ' + post.to_json
          next
        end

        begin
          post.save(:validate => false)
        rescue Exception => e
          puts e
          puts e.backtrace
          next
        end

        version = post.versions.last
        version.created_at = revision.created_at
        version.save
      end
    end
  end

  desc 'Convert subscriptions into posts'
  task subs: :environment do
    puts 'Converting subscriptions'
    Subscription.all.each do |sub|
      disc = Discussion.find_by_id(sub.discussion)
      if disc
        post = Post.find_by_uuid(disc.uuid)
        if post
          sub.post = post
          sub.save
        end
      end
    end
  end

  task :all => [:categories, :discussions, :replies, :subs]
end
