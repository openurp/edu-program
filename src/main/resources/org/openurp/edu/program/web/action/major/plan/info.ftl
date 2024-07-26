[#ftl]
  [@b.head /]
  <link rel="stylesheet" type="text/css" href="${b.base}/static/css/plan.css?v=20230522" />
  [#assign planStyle=Parameters['style']!"Default"]
[#macro i18nName(entity)][#if locale.language?index_of("en")!=-1][#if entity.enName?if_exists?trim==""]${entity.name?if_exists}[#else]${entity.enName?if_exists}[/#if][#else][#if entity.name?if_exists?trim!=""]${entity.name?if_exists}[#else]${entity.enName?if_exists}[/#if][/#if][/#macro]
[@b.toolbar title=plan.program.name/]
    [#assign maxTerm = plan.terms /]
<div align="center" class="container" style="font-family:宋体;">
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
        bg.form.submit(document.planForm,"${b.url('!info')}?id=${plan.id}&style=${planStyle}" + '&term=' + term);
    }
    </script>
    [#include "/org/openurp/edu/program/components/plan/libs.ftl" /]
    [@include_optional path="/org/openurp/edu/program/components/plan/extMacros.ftl"/]
    <p style="color:#00108c;font-weight:bold;font-size:13pt;margin:0px 5px;">[@exePlanTitle plan/]</p>
    [#include "/org/openurp/edu/program/components/plan/table_${planStyle}.ftl"/]
</div>

<div style="width:100%;text-align:center;">
    <p style="color:#666666">[@planSupTitle plan/]</p>
</div>

[@b.foot /]
