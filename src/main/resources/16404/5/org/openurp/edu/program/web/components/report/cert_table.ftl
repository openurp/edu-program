[#if approach.linkTable??]
[#assign cot = (doc.getTable(approach.linkTable).contents)!'<table border="1"></table>'/]
[#assign cot = cot?replace('border="0"','border="1"')/]
[#assign cot = cot?replace('<table border="1">','<table id="certificate_${program.id}" style="text-align:center;table-layout: auto;page-break-inside: avoid;margin-top:0.5rem;" class="doc-table">')/]
${cot}
<script>
  var certificate_caption='<caption style="caption-side: top;text-align: center;padding: 0px;">表 ${doc_table_index}：学院推荐学生在读期间考取的证书</caption>'
  [#assign doc_table_index = doc_table_index+1/]
  jQuery("#certificate_${program.id}").prepend(certificate_caption);
  //表头加粗居中
  var rows = document.getElementById("certificate_${program.id}").rows;
  //放过最后一行说明
  for(var i=0;i<rows.length-1;i++){
    var row = rows[i];
    if(row.cells.length==1){
      var text = row.cells[0].innerHTML;
      if(text.startsWith("（")){
        jQuery(row.cells[0]).css({'text-align':'left','font-weight':'bold'});
      }else{
        jQuery(row.cells[0]).css({'text-align':'left'});
      }
    }
  }
  jQuery(rows[rows.length-1].cells[0]).css({'text-align':'left','font-weight':'initial'});
</script>
[/#if]
