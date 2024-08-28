[#ftl]
[@b.head /]
<style>
  .toolbar-line{
    line-height:0rem;
  }
</style>
<div align="center" class="container">
   [@b.toolbar title=plan.program.name/]
   [@b.form name="planForm" action="!index"]
    <table class="grid-table" align="center" width="70%">
      <tr>
        <td class="darkColumn" width="20%">学期：</td>
        <td>
          <select name="term" style="width:100px" onchange="displayTerm(this.value);" >
          <option value="">所有学期</option>
          [#list plan.program.startTerm..plan.program.endTerm as i]
              <option value="${i}" [#if (Parameters['term']!'') == i?string] selected[/#if]>第${i}学期</option>
          [/#list]
          </select>
        </td>
      </tr>
    </table>
    [/@]
    <script>
    function displayTerm(term) {
        bg.form.submit(document.planForm,"${b.url('!info')}?id=${plan.id}" + '&term=' + term);
    }
    </script>
    [#include "/org/openurp/edu/program/web/components/report/style.ftl"/]
    [#include "/org/openurp/edu/program/web/components/report/plan.ftl" /]
</div>

[@b.foot /]
