[@b.head loadui=false smallText=false/]

  <center>
      <h1 style="color:green;text-align:center;" id="spinner-info">
          正在渲染,请稍后...
      </h1>
      <!-- spinner-border -->
      <div class="spinner-border" role="status">
          <span class="sr-only">Loading</span>
      </div>
  </center>
<div style="display:none">
  [#list plans as plan]
    [#assign rowsPerPage=300/]
    [#assign program = plan.program/]
    [#include "/org/openurp/edu/program/web/components/report/style-excel.ftl"/]
    [#include "/org/openurp/edu/program/web/components/report/plan.ftl"/]
  [/#list]

  [@b.form name="actionForm" action="!excel"]
    <input name="grade.id" type="hidden" value="${grade.id}"/>
    <input name="department.id" type="hidden" value="${department.id}"/>
    <input name="style" value="" type="hidden"/>
    <input name="tableHtml" value="" type="hidden"/>
    [@b.submit value="下载Excel"/]
  [/@]
</div>
  <script>
    jQuery(document).ready(function(){
      var tableHtml=""
      jQuery(".plan-table").each(function(i,e){tableHtml += e.outerHTML});
      document.actionForm['tableHtml'].value=tableHtml;

      var style="<style>"
      var rules = document.styleSheets[0].cssRules;
      for(var i=0;i<rules.length;i++){
        var rule = rules[i];
        style +=( rule.cssText+"\n");
      }
      style+="</style>"
      document.actionForm['style'].value=style;
      jQuery("#spinner-info").html("正在导出excel,请在下载中查看【${grade.name} ${department.name} 教学计划.xlsx】");
      setTimeout(function(){window.close();},20000);
      bg.form.submit(document.actionForm);
    });
  </script>
[@b.foot/]
