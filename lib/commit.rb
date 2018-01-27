# Represents a commit to a git repository.
class Commit
  attr_accessor :repository, :branch, :sha, :author, :message, :created_at, :deployed, :current

  def initialize(repository, branch, sha, author, message, created_at, deployed, current)
    @repository = repository
    @branch = branch
    @sha = sha
    @author = author
    @message = message
    @created_at = created_at
    @deployed = deployed
    @current = current
  end
end
