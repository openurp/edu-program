
[#assign cot = (doc.getTable("courseOutcome").contents)!'<table border="1"></table>'/]
[#--有的有边框，有的没有边框--]
[#assign cot = cot?replace('border="0"','border="1"')/]
[#assign cot = cot?replace('<table border="1">','<table id="course_outcome_matrix_${program.id}" style="text-align:center;page-break-inside:auto;" class="doc-table">')/]

[@p cot/]
  <script>
    jQuery(function(){
      //表头加粗居中
      var table = document.getElementById("course_outcome_matrix_${program.id}")
      jQuery(table).prepend("<thead>");

      var rows = table.rows;
      for(var i=0;i<2;i++){
        var row = rows[i];
        table.tBodies[0].removeChild(row)
        table.tHead.appendChild(row);
        for(var j=0;j< row.cells.length;j++){
          jQuery(row.cells[j]).css({'text-align':'center','font-weight':'bold'});
        }
      }
      if(table.tBodies[0].rows.length==0){
        table.removeChild(table.tBodies[0]);
      }
      //从第三行开始,课程所在的列靠左对其
      for(var i=2;i<rows.length;i++){
        var row = rows[i];
        var first = row.cells[0];
        var second = row.cells[1];
        if(first.rowSpan>1){
          second.style.textAlign="left";
          second.style.paddingLeft="10px";
        }else{
          first.style.textAlign="left";
          first.style.paddingLeft="10px";
        }
      }
      var outcome_matrix_caption='<caption style="caption-side: top;text-align: center;padding: 0px;">表 ${doc_table_index}：本专业课程设置与毕业要求达成的关系矩阵</caption>'
      [#assign doc_table_index = doc_table_index+1/]
      jQuery("#course_outcome_matrix_${program.id}").find("thead tr:nth-child(1) td:nth-child(2)").each(function(i,e){jQuery(e).css({'width':'30%'})})
      jQuery("#course_outcome_matrix_${program.id}").prepend(outcome_matrix_caption);
    });
  </script>
