[#ftl]
[#include "libs.ftl"/]
[@include_optional path="/org/openurp/edu/program/web/components/report/planMacros.ftl"/]
[#--以下输出内容--]
[@planHead plan/]
<table id="planInfoTable${plan.id}" class="plan-table" style="vnd.ms-excel.numberformat:@" width="100%">
    [#assign maxTerm=plan.terms /]
    [#if !courseTypeWidth??][#assign courseTypeWidth=5*maxFenleiSpan/][/#if]
    [#if !courseTypeMaxWidth??][#assign courseTypeMaxWidth=15/][/#if]
    [#if courseTypeWidth>courseTypeMaxWidth][#assign courseTypeWidth=courseTypeMaxWidth/][/#if]
    <thead>
        <tr align="center">
            <th rowspan="2" colspan="${maxFenleiSpan}" width="${courseTypeWidth}%">类别</th>
            <th rowspan="2" width="10%">序号</th>
            <th rowspan="2">课程名称</th>
            <th rowspan="2" width="5%">学分</th>
            [#if displayCreditHour]<th rowspan="2" width="5%">学时</th>[/#if]
            <th colspan="${maxTerm}" width="${maxTerm*3.5}%">开课学期</th>
            [#if displayTeachDepart]
            <th rowspan="2" width="10%">开课院系</th>
            [/#if]
            <th rowspan="2" width="${remarkWidth!7}%">备注</th>
        </tr>
        <tr>
        [#assign total_term_credit={} /]
        [#list plan.program.startTerm..plan.program.endTerm as i ]
            [#assign total_term_credit=total_term_credit + {i:0} /]
            <th width="[#if maxTerm?exists&&maxTerm!=0]${25/maxTerm}[#else]2[/#if]%" style="text-align:center">${i}</th>
        [/#list]
        </tr>
    </thead>
    <tbody>
    [#list plan.topGroups! as courseGroup]
        [@drawGroup courseGroup planCourseCreditInfo courseGroupCreditInfo/]
    [/#list]
        <tr>
            <td class="summary" colspan="${maxFenleiSpan + mustSpan}">全程总计</td>
            <td class="credit_hour summary">${plan.credits!(0)}</td>
            [#if displayCreditHour]<td class="credit_hour summary">${plan.creditHours}</td>[/#if]
        [#list plan.program.startTerm..plan.program.endTerm as i]
            <td>[#if total_term_credit[i?string]>0]${total_term_credit[i?string]}[/#if]</td>
        [/#list]
            [#if displayTeachDepart]<td>&nbsp;</td>[/#if]
            <td>&nbsp;</td>
        </tr>
        [#if plan.program.remark??]
        <tr>
            <td align="center" colspan="${maxFenleiSpan}">备注</td>
            [#assign remarkSpan = 3 + 1 +maxTerm/]
            [#if displayCreditHour][#assign remarkSpan =1+remarkSpan/][/#if][#if displayTeachDepart][#assign remarkSpan =1+remarkSpan/][/#if]
            [#assign remark = plan.program.remark?replace("\r","")/]
            <td colspan="${remarkSpan}" style="padding-left: 10px;line-height: 1.5rem;text-align:left;">${remark?replace('\n','<br>')}</td>
        </tr>
        [/#if]
    </tbody>
</table>
[@planFoot plan/]

<script>
[#assign bottomRows=1/]
[#if plan.program.remark??][#assign bottomRows=2/][/#if]
[@mergeCourseTypeCell plan teachPlanLevels bottomRows/]
mergeCourseTypeCell('planInfoTable${plan.id}');
</script>
