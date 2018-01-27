jQuery('#datepicker').datetimepicker({
    lazyInit: true,
    value: " ",
    format: 'm/d/Y H:i e',
    maxDate:'+1970/01/06',
    defaultDate: new Date(),
    minDate: "0",
    mask:true,
    startDate:new Date(),
    step: 5,
    formatTime: "g:i a",
    onChangeDateTime:function(ct,$i){
      $("#count").load("/scrims/server_count/?date=" + encodeURIComponent($i.val()) + "&length=" + $("#length").val());
    },
});

function loadCount(){
  $("#count").load("/scrims/server_count/?date=" + encodeURIComponent($("#datepicker").val()) + "&length=" + $("#length").val());
}
