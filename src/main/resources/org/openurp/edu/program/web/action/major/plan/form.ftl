[#ftl]
  [@b.head /]
  <link rel="stylesheet" type="text/css" href="${b.base}/static/edu/program/css/outline.css?v=1" />
  <script type="module" charset="utf-8" src="${b.base}/static/edu/program/js/outline.js"></script>
[#assign planStyle=Parameters['style']!"Default"]
[#macro i18nName(entity)][#if locale.language?index_of("en")!=-1][#if entity.enName?if_exists?trim==""]${entity.name?if_exists}[#else]${entity.enName?if_exists}[/#if][#else][#if entity.name?if_exists?trim!=""]${entity.name?if_exists}[#else]${entity.enName?if_exists}[/#if][/#if][/#macro]
[#assign maxTerm = plan.terms /]
[#assign program = plan.program/]
[#assign displayCourseEnName=true/]
[#assign programCourseTags = program.courseTags/]
[#assign readonlyCourseTypes=["长学段教学","长学段-通识课模块","长学段-通识限定选修课","数据与信息素养课程","体育限定选修",
                         "艺术审美类课程","长学段-通识自由选修课","社会科学类","科学技术类","创新创业类","国际视野类",
                         "长学段-学科专业课模块","跨学科跨专业选修课","长学段-专业与创新实践","创新创业实践","短学段教学","短学段-综合素质实践","综合能力素质测评"]/]
[#assign readonlyCourseNames=
         ["马克思主义基本原理","思想道德与法治","中国近现代史纲要","毛泽东思想和中国特色社会主义理论体系概论", "诚信教育",
         "习近平新时代中国特色社会主义思想概论","国家安全教育",
          "大学英语(一)","大学英语(二)","大学英语(三)","大学英语(四)","Python程序设计基础","体育(一)","体育(二)","体育(三)","体育(四)",
          "创业基础","职业规划与就业指导①","职业规划与就业指导②","心理健康①","心理健康②","军事理论",
          "形势与政策①","形势与政策②","形势与政策③","形势与政策④","形势与政策⑤","形势与政策⑥","形势与政策⑦","形势与政策⑧",
          "军事训练","马克思主义基本原理实践","思想道德与法治实践","中国近现代史纲要实践","毛泽东思想和中国特色社会主义理论体系概论实践",
          "习近平新时代中国特色社会主义思想概论实践","能力素质拓展课","大学生体质测试","大学生普通话水平测试","阅读能力","大学信息技术",
          "劳动教育与实践（一）","劳动教育与实践（二）"]/]
<style>
  .grouprow{
    background-color: #e9ecef;
    font-weight:bold;
    height: 38px;
  }
</style>
[#macro displayGroup(g,level)]
  <tr onmouseover="displayGroupOps(this)" onmouseout="hideGroupOps(this)" class="grouprow">
    <td colspan="3">
      <div style="display: inline-block;">
      ${g.indexno}&nbsp;
      [#if g.children?size==0 && g.planCourses?size==0]
       ${g.shortName}[#if g.credits>0](${g.credits}分)[/#if]
      [#else]
      <h${level} style="display:inline;">
        <a class="q-anchor q-heading-anchor" name="group${g.id}"></a>${g.shortName}[#if g.credits>0](${g.credits}分)[/#if]
      </h${level}>
      [/#if]
      </div>
      <div class="text-muted" style="display: inline-block;">
        [#--[#if !g.termCreditsEmpty]
        学分分布:${g.termCredits}
        [/#if]
        --]
      </div>
      <div style="text-align: center;display: inline-block;float:right;display:none;" class="group_op">
        [#if !readonlyCourseTypes?seq_contains(g.courseType.name)]
        <a href="#" class="btn btn-sm btn-outline-primary" onclick="return newPlanCourse('${g.id}');" style="padding:2px 2px"><i class="fa-solid fa-plus"></i>添加课程</a>
        [#if g.rank?? && !g.rank.compulsory][#--选修课开放修改--]
        <a href="#" class="btn btn-sm btn-outline-primary" onclick="return editCourseGroup('${g.id}');"  style="padding:2px 2px"><i class="fa-solid fa-pen-to-square"></i>修改</a>
        [/#if]
        [/#if]
      </div>
    </td>
    <td>[#if g.credits>0]${g.credits}[/#if]</td>
    <td>[#if g.creditHours>0]${g.creditHours}[#assign ghours = g.getHours(natures)/][#if ghours?size>0]([#list ghours?keys as h]${ghours.get(h)}[#sep]+[/#list])[/#if][/#if]</td>
    <td>${(g.rank.name)!}</td>
    <td></td>
    <td>[#if g.leaf]${termHelper.getTermText(g)!}[/#if]</td>
    <td>${g.departments!}</td>
    <td><span class="text-muted" style="font-size:0.8rem">${g.remark!}</span></td>
  </tr>

  [#if g.planCourses?size>0]
    [#list g.orderedPlanCourses as pc]
    <tr onmouseover="displayCourseOps(this)" onmouseout="hideCourseOps(this)">
      <td>${pc_index+1}</td>
      <td>${pc.course.code}</td>
      <td>
        <div style="display: inline-block;">
          <span class="course_name" id="pc_course_${pc.course.id}" [#if programCourseTags.get(pc.course)??]style="font-weight:bold;"[/#if]
                onclick="toggleCourseLabel(this,'${pc.course.id}','${pc.course.name?js_string}')">
                ${pc.course.name}[#if displayCourseEnName]<span class="en_course_name" style="display:none;[#if !pc.course.enName??]color:red;[/#if]"><br>${pc.course.enName!'MISSING ENGLISH NAME'}</span>[/#if]</span>
        </div>
        <div style="text-align: center;display: inline-block;float:right;display:none;" class="course_op">
          [#if !readonlyCourseTypes?seq_contains(g.courseType.name) && !readonlyCourseNames?seq_contains(pc.course.name)]
          <a href="#" onclick="return editPlanCourse('${pc.id}');" class="btn btn-sm btn-outline-primary"  style="padding:2px 2px"><i class="fa-solid fa-pen-to-square"></i>修改</a>
          [@b.a href="!removeCourse?planCourse.id="+pc.id onclick="if(confirm('确认删除${pc.course.name?js_string}?')){ return bg.Go(this)} else return false;"
           class="btn btn-sm btn-outline-danger" style="padding:2px 2px"]
          <i class="fa-solid fa-xmark"></i>删除
          [/@]
          [/#if]
        </div>
      </td>
      <td>${pc.course.defaultCredits}</td>
      [#assign cj = pc.course.getJournal(program.grade)/]
      <td>[#if cj.weeks?? && cj.weeks>0][#if cj.weeks>15]每周[#else]${cj.weeks}周[/#if][#else]${cj.creditHours}<span [#if cj.creditHourIdentical]class="text-muted"[#else]style="color:red"[/#if]>([#list natures as n]${cj.getHour(n)!0}[#sep]+[/#list])</span>[/#if]</td>
      <td>[#if pc.compulsory]必修[#else]${(g.rank.name)!}[/#if]</td>
      <td>${(cj.examMode.name)!}</td>
      <td>${termHelper.getTermText(pc)}<div style="display:none">${pc.terms!}</div></td>
      <td>${(cj.department.shortName!cj.department.name)!}</td>
      <td>
        <span class="text-muted" style="font-size:0.8rem">
        [#if cj.examMode.id==1]${cj.examMode.name}&nbsp;[/#if][#t/]
        [#if pc.remark?? && pc.remark?length>0]${pc.remark}&nbsp;[/#if][#t/]
        [#if programCourseTags.get(pc.course)??][#list programCourseTags.get(pc.course) as t]${t.name}&nbsp;[/#list][/#if][#t/]
        [#if cj.tags?size>0] [#list cj.tags as t]${t.name}[#sep]&nbsp;[/#list][/#if][#t/]
        </span>
      </td>
    </tr>
    [/#list]
  [/#if]
  [#if g.children?size>0]
      [#list g.children?sort_by("indexno") as gc]
      [@displayGroup gc,level+1/]
      [/#list]
  [/#if]
[/#macro]
<header>
  <nav class="navbar navbar-expand-lg navbar-light bg-light">
    [@b.a href="!edit?plan.id="+plan.id class="navbar-brand"]${program.grade.code}级 ${program.level.name} ${program.department.name} ${program.major.name}  ${(program.direction.name)!}教学计划[/@]
    <ul class="navbar-nav ml-auto">
      <li class="nav-item">
        [@b.a href="doc!edit?program.id="+program.id class="nav-link" target="_blank"]修改文本内容[/@]
      </li>
      <li class="nav-item">
        [@b.a href="!restat?plan.id="+plan.id class="nav-link"]统计学分学时[/@]
      </li>
      <li class="nav-item">
        [@b.a href="revise!info?id="+program.id class="nav-link" target="_blank"]查看核对[/@]
      </li>
      <li class="nav-item">
        <a href="#"class="nav-link" onclick="return toggleEnCourseName(this)">显示课程英文名</a>
      </li>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-expanded="false" id="term_nav">
          按学期查看
        </a>
        <div class="dropdown-menu">
          [#list program.startTerm .. program.endTerm as term]
          <a class="dropdown-item" href="#" onclick="filterCourseByTerm('${term}')">第${term}学期</a>
          [/#list]
          <a class="dropdown-item" href="#" onclick="filterCourseByTerm('')">全部学期</a>
        </div>
      </li>
      <li>
         <div class="input-group input-group-sm">
           <input class="form-control" type="search" name="q" onchange="return searchCourse(this.value);" value=""  placeholder="输入搜索关键词">
           <div class="input-group-append">
             <button class="input-group-text" type="submit">
               <i class="fas fa-search"></i>
             </button>
           </div>
         </div>
      </li>
    </ul>
  </nav>
</header>

<div id="page-body">
  <aside id="page-left-aside">
    <div id="catalogs" class="page-body-module">
      <div class="page-body-module-title">课程分组 ${plan.credits}</div>
      <div class="page-body-module-content"></div>
    </div>
  </aside>
  <main>
  [@b.messages slash="3"/]
    <article id="article" class="page-body-module" data-id="2">
      <div class="page-body-module-content">
        <table style="width: 100%;table-layout: fixed;" id="course_header" class="table table-sm">
          <thead style="position: sticky;top:-56px;">
            <tr>
              <th width="40px">序号</th>
              <th width="10%">课程代码</th>
              <th>课程名称以及英文名</th>
              <th width="5%">学分</th>
              <th width="10%">学时</th>
              <th width="70px">课程属性</th>
              <th width="70px">考核方式</th>
              <th width="70px">开课学期</th>
              <th width="70px">开课单位</th>
              <th width="120px">备注</th>
            </tr>
          </thead>
          <tbody>
          [#list plan.topGroups as g]
          [@displayGroup g,1/]
          [/#list]
          </tbody>
        </table>
      </div>
      [#--此处为鼠标悬浮的div--]
      [#list tags as tag]
      <div id="tag_${tag.id}" style="position:absolute;color:red;display:none;">${tag.name}</div>
      [/#list]
    </article>
  </main>
  <aside id="page-right-aside">
    <div id="toolboxes">
      <div class="page-body-module">
        <div class="page-body-module-title"><i class="fa-solid fa-flag"></i> 计划检查汇总信息</div>
        <div class="page-body-module-content">
           <div class="alert alert-warning" id="plan_summary_errors"></div>
           <div class="alert alert-info" id="plan_summary_warnings"></div>
        </div>
        [#list tags as tag]
        <div class="page-body-module-title"><i class="fa-solid fa-tags"></i> ${tag.name} <button onclick="toggleTag(this,'${tag.id}');return false;"  style="padding:0px 0px;border:0px;" class="btn btn-sm btn-outline-primary">开始标记</button></div>
        <div class="page-body-module-content">
           <ol id="tag_${tag.id}_courses" style="padding-left:2rem;margin-bottom:0px;">
           [#list program.labels as l]
             [#if l.tag == tag]<li>${l.course.name}</li>[/#if]
           [/#list]
           </ol>
        </div>
        [/#list]
        [#if isAdmin]
        <div class="page-body-module-title"><i class="fa-solid fa-file-excel"></i> 计划导入</div>
        <div class="page-body-module-content">
          [@b.form name="newCourse" action="!importData?plan.id="+plan.id]
            [@b.file name="plan_file" label="文件" class="form-control mr-sm-2" type="file" placeholder="Excel电子表格"/]
            [@b.submit class="btn btn-outline-primary"/]
          [/@]
        </div>
        [/#if]
      </div>
    </div>
  </aside>
</div>

<!-- courseListDialog -->
<div class="modal fade" id="courseListDialog" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">课程信息</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
       [@b.div id='planDialogBody' href="!courses?plan.id=${plan.id}" style="width:100%"/]
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">关闭</button>
        <button type="button" onclick="chooseCourseToPlanCourse()" class="btn btn-primary">确定</button>
      </div>
    </div>
  </div>
</div>

<!-- PlanCourseFormDiv -->
<div class="modal fade" id="planCourseFormDiv" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered" role="document" style="width:900px">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">设置课程信息 (<span id="planCourse_group_name" class="text-muted" style="font-size:0.8em;"></span>)</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        <form name="planCourseForm" method="post" action="${b.url('!saveCourse')}">
            <input type="hidden" name="planId" value="${plan.id}"/>
            <input type="hidden" name="planCourse.group.id" value=""/>
            <input type="hidden" name="stage" value=""/>
            <input type="hidden" name="planCourse.id" value=""/>
            <input type="hidden" name="planCourse.course.id" id="planCourse_course_id" value=""/>
            <table width="100%" valign="top" class="grid-table">
               <tr>
                 <td class="grayStyle" width="25%">&nbsp;课程代码<font color="red">*</font></td>
                 <td class="brightStyle" colspan="3">
                      <input type="text" name="planCourse.course.code" id="planCourse_course_code" value="" readonly size="20" maxlength="20"/>
                      <input type="button" value="选择课程" onclick="openCourseListDialog();"  class="buttonStyle"/>
                 </td>
               </tr>
               <tr>
                 <td class="grayStyle" width="25%">&nbsp;课程名称<font color="red">*</font></td>
                 <td class="brightStyle" colspan="3">
                   <span id='planCourse_course_name'></span>&nbsp;
                   <span id='planCourse_course_defaultCredits'></span>学分
                   <span id='planCourse_course_creditHours'></span>学时
                 </td>
               </tr>
               <tr>
                 <td class="grayStyle" width="25%">&nbsp;开课院系</td>
                 <td class="brightStyle" colspan="3"><span id='planCourse_department_name'></span></td>
               </tr>
               <tr>
                 <td class="grayStyle" width="25%">&nbsp;开课学期<font color="red">*</font></td>
                 <td class="brightStyle" colspan="3">
                    <input type="text" name="planCourse.terms" id="planCourse_terms" size="10" title="开课学期" maxlength="50" value="" onchange="generateTermText(this)"/>
                    <span style="font-size:0.8rem;color: #999;">格式为:1或者1,2  *表示不限</span>
                 </td>
               </tr>
               <tr>
                   <td class="grayStyle" width="25%">&nbsp;开课学期说明</td>
                   <td class="brightStyle" colspan="3">
                       <input name="planCourse.termText" id="planCourse_termText" value=""/>
                   </td>
               </tr>
               <tr>
                 <td class="grayStyle" width="25%">&nbsp;开课周</td>
                 <td class="brightStyle" colspan="3">
                      <input type="text" name="planCourse.weekstate" size="10" maxlength="50" value=""/>
                      <span style="font-size:0.8rem;color: #999;">格式为:1或者1,2;1-8;1-15单</span>
                 </td>
               </tr>
               <tr>
                 <td class="grayStyle" width="25%">&nbsp;顺序号</td>
                 <td class="brightStyle" colspan="3">
                      <input type="text" name="planCourse.idx" style="width:40px" maxlength="3" value=""/>
                      <span style="font-size:0.8rem;color: #999;">整数1开始，默认为0,按照学期排序+代码排序</span>
                 </td>
               </tr>
               <tr>
                 <td class="grayStyle">&nbsp;备注</td>
                 <td class="brightStyle" colspan="3"><textarea name="planCourse.remark" id="planCourse_remark" cols="25" rows="2"></textarea></td>
               </tr>
            </table>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">关闭</button>
        <button type="button"  onclick="savePlanCourse();"  class="btn btn-primary">确定</button>
      </div>
    </div>
  </div>
</div>

<!-- CourseGroupFormDiv -->
<div class="modal fade" id="courseGroupFormDiv" tabindex="-1" role="dialog" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">设置课程组信息</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body" id="course_group_edit_div">
      </div>
    </div>
  </div>
</div>

<script>
beangle.load(["jquery-validity","jquery-colorbox"]);

var currentTagId="0";
function addMouseTag(e){
  var rect = document.getElementById('article').getBoundingClientRect();
  var x = e.clientX+10;
  var y = e.clientY - rect.top + 56;//top nav height;
  let tag = document.getElementById("tag_"+currentTagId);
  tag.style.left = x + "px";
  tag.style.top = y + "px";
}

function toggleTag(e,tagId){
  if(currentTagId != "0"){
    document.getElementById("tag_"+currentTagId).style.display="none";
    document.getElementById('article').removeEventListener("mousemove", addMouseTag);
  }
  if(e.innerHTML=='开始标记'){
    e.innerHTML="完成标记";
    e.style.color="red";
    currentTagId=tagId;
    document.getElementById("tag_"+currentTagId).style.display="";
    document.getElementById('article').addEventListener("mousemove", addMouseTag);
  }else{
    e.style.color="";
    jQuery.ajax({
      type:"post",
      url:"${b.url('!updateLabel')}",
      data:"program.id=${program.id}&tag.id="+currentTagId+"&courseIds="+(Array.from(tagCourses['tag'+currentTagId]).join(",")),
      success:function(data){
       if(data=="ok"){
          alert("标记完成");
          validatePlan();
       }
      }
    });

    currentTagId="0";
    e.innerHTML="开始标记";
  }
}

function toggleCourseLabel(courseElem,courseId,courseName){
  if(currentTagId != "0"){
     if(tagCourses['tag'+currentTagId].has(courseId)){
       tagCourses['tag'+currentTagId].delete(courseId);
       jQuery("#tag_"+currentTagId+"_courses").append("<li>"+courseName+"</li>");
       jQuery("#tag_"+currentTagId+"_courses li").each(function (i,e){
          if(e.innerHTML==courseName){
            e.parentNode.removeChild(e);
          }
       });
       courseElem.style.fontWeight="normal";
     }else{
       tagCourses['tag'+currentTagId].add(courseId);
       jQuery("#tag_"+currentTagId+"_courses").append("<li>"+courseName+"</li>");
       courseElem.style.fontWeight="bold";
     }
  }
}

var tagCourses = {};
var planCourses = {};
var courseGroups = [];
[#list tags as tag]
tagCourses['tag${tag.id}']=new Set();
[/#list]
[#list program.labels as l]
  tagCourses['tag${l.tag.id}'].add("${l.course.id}");
[/#list]

[#list plan.groups as g]
    courseGroups.push({'id':'${g.id}','name':'${g.name}','stage':'${(g.stage.name)!}'});
    [#list g.planCourses as pc]
      [#assign c=pc.course/]
      planCourses['pc${pc.id}']={'id':'${pc.id}','groupId':'${pc.group.id}','terms':'${pc.terms}','compulsory':${pc.compulsory?c},'course':{'id':'${c.id}','code':'${c.code}','name':'${c.name}','defaultCredits':'${c.defaultCredits}','creditHours':'${c.creditHours}','weekHours':'${c.weekHours}','department':{'id':'${c.department.id}','name':'${c.department.name}'}},'termText':'${(pc.termText!"")?js_string}','remark':'${(pc.remark!"")?js_string}','idx':'${pc.idx}'}
    [/#list]
[/#list]

  function findGroup(groupId){
    for(i=0;i<courseGroups.length;i++){
      if(courseGroups[i].id==groupId){
        return courseGroups[i];
      }
    }
    return null;
  }

  function validatePlan(){
    jQuery.ajax({
      type:"post",
      url:"${b.url('!validate')}.json",
      data:"plan.id=${plan.id}",
      success:function(data){
        if(data.errors.length>0){
          jQuery("#plan_summary_errors").html("");
          data.errors.forEach(function(e){  jQuery("#plan_summary_errors").append("<li>"+e+"</li");});
          jQuery("#plan_summary_errors").show();
        }else{
          jQuery("#plan_summary_errors").hide();
        }
        if(data.messages.length>0){
          jQuery("#plan_summary_warnings").html("");
          data.messages.forEach(function(e){  jQuery("#plan_summary_warnings").append("<li>"+e+"</li>");});
          jQuery("#plan_summary_warnings").show();
        }else{
          jQuery("#plan_summary_warnings").hide();
        }
      }
    });
  }
  function openCourseListDialog() {
    jQuery("#planCourseFormDiv").modal('hide');
    jQuery("#courseListDialog").modal('show');
  }
  function openPlanCourseDialog() {
    jQuery("#courseListDialog").modal('hide');
    jQuery("#planCourseFormDiv").modal('show');
  }

  function clearPlanCourseForm() {
    var planCourseForm = document.planCourseForm;
    planCourseForm["planCourse.course.id"].value = '';
    planCourseForm["planCourse.terms"].value = '';
    planCourseForm["planCourse.termText"].value='';
    planCourseForm["planCourse.weekstate"].value = '';
    planCourseForm["planCourse.idx"].value = '0';
    jQuery('#planCourse_course_name').html('');
    jQuery('#planCourse_course_credits').html('');
    jQuery('#planCourse_course_creditHours').html('');
    jQuery(planCourseForm["planCourse.remark"]).html('');
  }

  function _fillFormCoursePart(course) {
    var planCourseForm = document.planCourseForm;
    clearPlanCourseForm();
    planCourseForm["planCourse.course.id"].value = course.id;
    planCourseForm["planCourse.course.code"].value = course.code;
    jQuery('#planCourse_course_name').html(course.name);
    if(course.department != null) {
      jQuery('#planCourse_department_name').html(course.department.name);
    }
    jQuery('#planCourse_course_defaultCredits').html(course.defaultCredits);
    if(course.creditHours != null) {
      jQuery('#planCourse_course_creditHours').html(course.creditHours);
    }
  }

  function newPlanCourse(groupId) {
    var form = document.planCourseForm;
    form["planCourse.id"].value = '';
    form["planCourse.terms"].value = '';
    var g = findGroup(groupId);
    form['planCourse.group.id'].value = g.id;
    form['stage'].value = g.stage;
    jQuery('#planCourse_group_name').html(g.name);
    clearPlanCourseForm();
    openCourseListDialog();
    return false;
  }

  function editPlanCourse(id) {
    var planCourse=planCourses['pc'+id];
    _fillFormCoursePart(planCourse.course);

    var form = document.planCourseForm;
    form['planCourse.id'].value = planCourse.id;
    var g = findGroup(planCourse.groupId);
    form['planCourse.group.id'].value = g.id;
    form['stage'].value = g.stage;
    jQuery('#planCourse_group_name').html(g.name);
    form['planCourse.terms'].value = planCourse.terms.replace(/^,/, '').replace(/,$/, '');
    if(!form['planCourse.terms'].value) form['planCourse.terms'].value="*";
    form['planCourse.termText'].value = planCourse.termText;
    form['planCourse.idx'].value = planCourse.idx;
    if(planCourse.weekstate) form['planCourse.weekstate'].value = planCourse.weekstate;
    if(null != planCourse.remark) {
      jQuery(form['planCourse.remark']).html(planCourse.remark);
    } else {
      jQuery(form['planCourse.remark']).html('');
    }
    openPlanCourseDialog();
    return false;
  }

  function editCourseGroup(id) {
     jQuery("#courseGroupFormDiv").modal('show');
     bg.Go('${b.url("!editGroup?plan.id=${plan.id}")}&courseGroup.id='+id,'course_group_edit_div')
  }
  function chooseCourseToPlanCourse() {
    var id = jQuery(':checked[name=course\\.id]', jQuery('#planDialogBody')).val();
    if (id == undefined || id == "") {
        alert('请选择课程');
        return;
    }
    _fillFormCoursePart(courseResults['c'+id]);
    openPlanCourseDialog();
  }
  /**
   * 保存培养计划中的课程
   */
  function savePlanCourse() {
    if(validatePlanCourse()) {
      closePlanCourseDialog();
      bg.form.submit(document.planCourseForm, '${b.url('!saveCourse')}');
    }
  }
  // 验证培养计划的课程
  function validatePlanCourse() {
    var form = document.planCourseForm;

    var terms = jQuery('input[name=planCourse\\.terms]', jQuery(form)).val();
    jQuery('input[name=planCourse\\.terms]', jQuery(form)).val(terms.replace(/，/g, ','));

    var res = null;
    jQuery.validity.start();
    jQuery('#planCourse_course_id').require();
    jQuery('#planCourse_terms').assert(
        function(termInput) {
          return checkTerms(termInput, ${plan.program.startTerm},${plan.program.endTerm});
        }
        ,
        '开课学期为数字${plan.program.startTerm}-${plan.program.endTerm}和,组成,不指定学期请输入星号*'
    ).require();
    jQuery('#planCourse_remark').maxLength(500);
    res = jQuery.validity.end().valid;
    if(false == res) {
      return false;
    }
    return true;
  }
  function checkTerms(termInput, startTerm,endTerm) {
    if(!termInput)return false;
    var termArr = termInput.value.split(',').sort();
    var termArr_ = new Array();
    var prev = '';
    for(var i = 0; i < termArr.length; i++) {
      if(prev != termArr[i]) {
        termArr_.push(termArr[i]);
        prev = termArr[i];
      }
    }
    termArr = termArr_;
    termInput.value = termArr.join(',');

    for(var i = 0; i < termArr.length; i++) {
      if((!/^[1-9]\d*$/.test(termArr[i]) &&
       jQuery.trim(termArr[i])!='春季' &&
       jQuery.trim(termArr[i])!='秋季' &&
       jQuery.trim(termArr[i])!='春秋季')&&
       !/^\*$/.test(termArr[i])) {
        return false;
      }
      if(new Number(termArr[i]) > endTerm || new Number(termArr[i]) < startTerm) {
        return false;
      }
    }

    termArr.sort(function(a,b) {
      return new Number(a) - new Number(b);
    });
    termInput.value = termArr.join(',');
    return true;
  }
  function closePlanCourseDialog() {
    closeDialog("planCourseFormDiv");
  }
  function closeDialog(id){
    jQuery("#"+id).modal('hide');
    jQuery("body>div.modal-backdrop").remove();
    return true;
  }
  function displayCourseOps(trElem){
    jQuery(trElem).find("td:nth-child(3) div.course_op").show();
  }
  function hideCourseOps(trElem){
    jQuery(trElem).find("td:nth-child(3) div.course_op").hide();
  }
  function displayGroupOps(divElem){
    jQuery(divElem).find("div.group_op").show();
  }
  function hideGroupOps(divElem){
    jQuery(divElem).find("div.group_op").hide();
  }
  function searchCourse(q){
    q= q.toUpperCase().trim();
    jQuery("#article table tr td span.course_name").each(function(i,e){
      var matched = (q=="" || e.innerHTML.indexOf(q) > -1);
      if(matched){
        jQuery(e).parents("tr").show();
      }else{
        jQuery(e).parents("tr").hide();
      }
    });
    return false;
  }
  function filterCourseByTerm(term){
    jQuery("#article table tr td:nth-child(8) div").each(function(i,e){
      var matched = (term=="" || e.innerHTML.split(",").includes(term));
      if(matched){
        jQuery(e).parents("tr").show();
      }else{
        jQuery(e).parents("tr").hide();
      }
    });
    if(term==""){
      jQuery("#term_nav").html("全部学期")
    }else{
      jQuery("#term_nav").html("第"+term+"学期")
    }
    return false;
  }
  //根据输入的学期自动生成学期说明
  function generateTermText(termInput){
    var form = termInput.form;
    var stage=form['stage'].value||"";
    if(stage.length>0){
      var sn = stage.substring(0,1);
      var terms = termInput.value;
      terms = terms.replace('-',sn+'-')
      terms = terms.replace(',',sn+'+')
      terms+=sn;
      form['planCourse.termText'].value=terms;
    }
  }
  function toggleEnCourseName(e){
    if(e.innerHTML=="隐藏课程英文名"){
      jQuery(".en_course_name").hide()
      e.innerHTML="显示课程英文名";
    }else{
      jQuery(".en_course_name").show()
      e.innerHTML="隐藏课程英文名";
    }
    return false;
  }
  // final step
  validatePlan();
  setTimeout(function(){
    jQuery("head base").remove();
    document.title="${program.major.name}  ${(program.direction.name)!} ${program.grade.code}级 ${program.level.name} 教学计划"
  },2000);
</script>
[@b.foot /]
