[#ftl]
[@b.head/]
[#include "planGroupFunctions.ftl" /]
<link rel="stylesheet" type="text/css" href="${b.base}/static/css/plan.css?v=20230522" />

[@b.messages slash="2"/]
<div class="row">
  <div class="col-3">
  <table id="courseGroupListTable" width="100%" style="font-size: 0.9em;margin-top: 0px;">
      <caption style="caption-side: top;">
      [@b.toolbar title='课程组列表(${plan.credits}分)']
         bar.addItem("新建","addGroup()");
         bar.addItem("复制","copyCourseGroupSetting()");
      [/@]
      </caption>
      <thead>
          <tr>
              <th>课程组</th>
              <th width="66px">操作</th>
          </tr>
      </thead>
      <tbody>
      [#assign first_active_finded=false/]
  [#list plan.groups?sort_by("indexno") as group]
      <tr data-tt-id="node-${group.id}" id="node-${group.id}" [#if group.parent??] data-tt-parent-id='node-${group.parent.id}'[/#if] [#if !(first_active_group??) && group.planCourses?size>0]class="treeNode-selected"[#assign first_active_group=group/][/#if]>
          <td class='treeNode' style="padding-left:10px;">
              <input type="hidden" name="groupId" value="${group.id}"/>
              [#assign groupName][#if group.givenName??]${group.givenName}[#else]${group.courseType.name}[/#if][/#assign]
              [#if groupName?length>10]
              <span style="font-size:0.8em">${groupName}</span>
              [#else]
              ${groupName}
              [/#if]
              [#assign subCreditSum=0/]
              [#list group.children as c]
                [#assign subCreditSum = subCreditSum + c.credits/]
              [/#list]
              [#list group.planCourses as pc]
                [#assign subCreditSum = subCreditSum + pc.course.defaultCredits/]
              [/#list]
              [#if group.children?size==0][#assign subCreditSum = group.credits/][/#if]
              <span style="font-size:0.8em;[#if subCreditSum != group.credits && subCreditSum >0 ]color:red[/#if]" title="子组要求学分为${subCreditSum}">
                (${group.credits}分 [#if group.subCount>0]${group.subCount}组[/#if])
              </span>
          </td>
          <td class='groupButton'>[@editButton group/][@removeButton group/]</td>
      </tr>
  [/#list]
      </tbody>
  </table>

  [@b.form name="actionForm" action="!info?id=1"]
      <input type="hidden" name="planId" value="${plan.id}"/>
      <input type="hidden" name="courseGroup.id" value="" />
  [/@]
  </div>
  [@b.div id="group_plan_course_list" class="col-9" /]
</div>

<script language="javascript">
    jQuery(function() {
        beangle.load(["jquery-treetable"],function(){
         jQuery('#courseGroupListTable').treetable({initialState : "expanded"});
        });
        jQuery('#courseGroupListTable tbody tr').hover(
            function(event) {
                jQuery('#courseGroupListTable tbody tr').removeClass('treeNode-hover');
                if(this.className.indexOf('treeNode-selected') == -1) {
                    jQuery(this).addClass('treeNode-hover');
                }
            },
            function(event) {
                jQuery(this).removeClass('treeNode-hover');
            }
        );
        jQuery('#courseGroupListTable tbody tr').click(function(event) {
            jQuery('#courseGroupListTable tbody tr').removeClass('treeNode-selected');
            jQuery(this).addClass('treeNode-selected');
            arrangeGroupCourses(this.id.substring("node-".length));
        });

        jQuery('#courseGroupListTable button').hover(
            function(event) { jQuery(this).addClass('ui-state-hover'); },
            function(event) { jQuery(this).removeClass('ui-state-hover');}
        );
        jQuery('#courseGroupListTable button').mousedown(
            function(event) { jQuery(this).addClass('ui-state-active'); }
        );
        jQuery('#courseGroupListTable button').mouseup(
            function(event) { jQuery(this).removeClass('ui-state-active');}
        );
    });

    var form = document.actionForm;

    function getSelectedId() {
        return jQuery('#courseGroupListTable tbody tr.treeNode-selected :hidden').val() || '';
    }

    function removeGroup(id) {
      if(false==confirm('确定要删除记录吗?')){
        return;
      }
      form['courseGroup.id'].value = id;
      bg.form.submit(form, '${b.url("!removeGroup?toGroups=1")}');
    }

    function addGroup() {
      bg.form.addInput(form,"courseGroup.id","");
      bg.form.submit(form, '${b.url("!editGroup?toGroups=1")}');
    }

    function edit(id) {
        bg.form.addInput(form,"courseGroup.id",id);
        bg.form.submit(form, '${b.url("!editGroup?toGroups=1")}');
   }

   function arrangeGroupCourses(id) {
      form['courseGroup.id'].value = id;
      bg.form.submit(form, '${b.url("!groupCourses")}',"group_plan_course_list");
   }
   [#if  first_active_group??]
      arrangeGroupCourses("${first_active_group.id}");
   [/#if]

   function copyCourseGroupSetting() {
     var id = getSelectedId();
     if(id==""||id.indexOf(",")>0||id==null){
       alert("请选择一项");
       return;
     }
     bg.form.addInput(form, "majorPlanCourseGroupId", id);
     bg.form.submit(form, "${b.base}/majorCourseGroup!copyCourseGroupSetting.action");
   }

   function groupMoveDown(courseGroupId) {
     form['courseGroup.id'].value = courseGroupId;
     bg.form.submit(form, "${b.base}/majorCourseGroup!groupMoveDown.action");
   }

   function groupMoveUp(courseGroupId) {
     form['courseGroup.id'].value = courseGroupId;
     bg.form.submit(form, "${b.base}/majorCourseGroup!groupMoveUp.action");
   }
</script>
[@b.foot/]
