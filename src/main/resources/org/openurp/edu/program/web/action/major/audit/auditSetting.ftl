[@b.head /]
  <link rel="stylesheet" type="text/css" href="${b.base}/static/edu/program/css/plan.css" />
  <script type="module" charset="utf-8" src="${b.base}/static/edu/program/js/plan.js"></script>
  <style>
  body{
    font-family:'Times New Roman',宋体;
  }
  .section{
    margin-top:.5rem;
  }
  .grouprow{
    background-color: #e9ecef;
    font-weight:bold;
  }
  </style>
[#assign labelCourses = []/]
[#list program.labels as l]
  [#assign labelCourses = labelCourses+[l.course]/]
[/#list]
[#assign maxTerm = plan.terms /]
[#assign displayCourseEnName=true/]
[@b.messages slash="3"/]
<header>
  <nav class="navbar navbar-expand-lg navbar-light bg-light">
    [@b.a href="!auditSetting?program.id="+program.id class="navbar-brand"]${program.grade.code}级 ${program.level.name} ${program.department.name} ${program.major.name}  ${(program.direction.name)!} 专业培养方案[/@]
    <ul class="navbar-nav ml-auto">
      <li class="nav-item">
        [@b.a href="!report?id="+program.id class="nav-link"]<i class="fa-solid fa-print"></i>打印预览[/@]
      </li>
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-expanded="false" id="term_nav">
          按学期查看
        </a>
        <div class="dropdown-menu">
          [#list program.startTerm .. program.endTerm as term]
          <a class="dropdown-item" href="#" onclick="return filterCourseByTerm('${term}')">第${term}学期</a>
          [/#list]
          <a class="dropdown-item" href="#" onclick="return filterCourseByTerm('')">全部学期</a>
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
      <div class="page-body-module-title">章节</div>
      <div class="page-body-module-content"></div>
    </div>
  </aside>
  <main>
    <article id="article" class="page-body-module" style="padding:10px 20px;">
      <div class="page-body-module-content">
      [#if doc??]
        [#include "../revise/docinfo.ftl"/]
      [/#if]
      <div>
        <h1>
          <a class="q-anchor q-heading-anchor" name="九、专业教学计划表（附表）"></a>九、专业教学计划表（附表）
        </h1>
      </div>
        [#include "../revise/planinfo.ftl"/]
    </article>
  </main>
  <aside id="page-right-aside">
    <div id="toolboxes">
      <div class="page-body-module">
        [#list tags as tag]
        <div class="page-body-module-title"><i class="fa-solid fa-tags"></i> ${tag.name}</div>
        <div class="page-body-module-content">
           <ol id="tag_${tag.id}_courses" style="padding-left:2rem;">
           [#list program.labels as l]
             [#if l.tag == tag]<li>${l.course.name}</li>[/#if]
           [/#list]
           </ol>
        </div>
        [/#list]
      </div>
      <div>
        [@b.form name="auditForm" action="!audit" theme="list" title="方案审核"]
          [#assign passedValue][#if program.status.id==50||program.status.id=100||program.status.id<2]1[#else]0[/#if][/#assign]
          [@b.radios name="passed" value=passedValue label="是否同意" required="true" onclick="resetOpinion(this)"/]
          [@b.textarea name="program.opinions" id="auditOpinion" required="true" rows="4" style="width:80%" value=program.opinions!
                       label="审核意见" placeholder="请填写意见"/]
          [@b.formfoot]
            <input type="hidden" name="program.id" value="${program.id}"/>
            [@b.submit value="action.submit"/]
          [/@]
        [/@]
        <script>
          function resetOpinion(ele){
            var reject=jQuery(ele).val()=='0';
            if(reject) {
              jQuery("#auditOpinion").val('');
            }else{
              jQuery("#auditOpinion").val('同意');
            }
          }
        </script>
      </div>
    </div>
  </aside>
</div>

<script>
  function searchCourse(q){
    q= q.toUpperCase().trim();
    jQuery("#article table.plan_table tr td span.course_name").each(function(i,e){
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
    jQuery("#article table.plan_table tr td:nth-child(8) div").each(function(i,e){
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
  setTimeout(function(){jQuery("head base").remove();},1000);
</script>
[@b.foot /]
