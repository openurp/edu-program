[#ftl/]
@startuml
left to right direction
'skinparam linetype ortho
'skinparam packageStyle
'skinparam nodesep 100
'skinparam ranksep 10
[#assign termNames=["第一学期","第二学期","第三学期","第四学期","第五学期","第六学期","第七学期","第八学期"]/]
[#list termGroups as group]
[#if group?size>0]
[#list group as c]
rectangle "${c.terms} ${c.course.name?js_string}" as c${c.course.id}
[/#list]
[/#if]
[/#list]

[#list prerequisites as pre]
[#assign preTerm = courseTerms.get(pre.prerequisite) /]
[#assign courseTerm = courseTerms.get(pre.course) /]
[#if preTerm == courseTerm]
c${pre.prerequisite.id} -d-> c${pre.course.id}
[#else]
c${pre.prerequisite.id} --> c${pre.course.id}
[/#if]
[/#list]
@enduml
