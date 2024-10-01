[#ftl]
[@b.head/]
<div class="container-fluid">
[#macro display group]
  [#list group.children as child]
    [@display child/]
  [/#list]
  [#assign groupTitle]${group.courseType.name} [#if group.language??]${group.language.name}[/#if] [#if group.courseAbilityRate??]${group.courseAbilityRate.name}[/#if][/#assign]
  <tr>
    <td colspan="7" style="text-align:left;font-weight:bold" class="text-muted">${group.indexno} ${groupTitle}</td>
  </tr>
  [#list group.planCourses as pc]
    <tr>
      <td>${pc_index+1}</td>
      <td>${pc.course.code}<input type="hidden" value="${groupTitle}" name="groupName"></td>
      <td>
        [#if enableLinkCourseInfo]
         <a href="${ems_base}/edu/course/profile/info/${pc.course.id}" target="_blank">${pc.course.name}</a>
        [#else]
          ${pc.course.name}
        [/#if]
      </td>
      <td><span class="text-muted">${(pc.course.enName)!}</span></td>
      <td>${pc.course.getCredits(plan.level)}</td>
      <td>${pc.course.creditHours}</td>
      <td>${pc.course.department.name}</td>
    </tr>
  [/#list]
[/#macro]
  <div style="text-align:center;vnd.ms-excel.numberformat:@;width:90%;margin:auto">
    <h5>${plan.name} </h5>
    <div class="input-group input-group-sm" style="width: 50%;margin: auto;">
      <input class="form-control form-control-navbar" type="search" name="q" id="course_query_item" value=""
             aria-label="Search" placeholder="输入关键词，课程类型、课程代码或名称" autofocus="autofocus"
             onchange="return search(this.value);">
      <div class="input-group-append">
        <button class="input-group-text" type="submit" onclick="return search(document.getElementById('course_query_item').value);">
          <i class="fas fa-search"></i>
        </button>
      </div>
    </div>
    <div class="grid-content">
      <table class="table table-sm" id="share_plan_table">
        <thead>
          <tr>
            <th width="5%">序号</th>
            <th width="10%">课程代码</th>
            <th width="20%">课程名称</th>
            <th width="35%">英文名称</th>
            <th width="7%">学分</th>
            <th width="8%">学时</th>
            <th width="15%">开课院系</th>
          </tr>
        </thead>
        <tbody>
        [#list plan.groups?sort_by("indexno") as group]
          [#if !(group.parent??)]
            [@display group/]
          [/#if]
        [/#list]
        </tbody>
      </table>
    </div>
  </div>
</div>
<script>
   function search(q){
    jQuery("#share_plan_table tbody tr").each(function(i,e){
      var tds = jQuery(e).children("td");
      var matched = (q=="") || tds.length<2;
      if(!matched){
        for(var idx=0;idx < tds.length;idx++){
          if(q=='' || tds[idx].innerHTML.indexOf(q)>-1){
            matched=true;
            break;
          }
        }
      }
      if(matched){
        jQuery(e).show();
      }else{
        jQuery(e).hide();
      }
    });
    return false;
   }
</script>
[@b.foot/]
