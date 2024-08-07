[@b.head /]
  <link rel="stylesheet" type="text/css" href="${b.base}/static/edu/program/css/outline.css" />
  <script type="module" charset="utf-8" src="${b.base}/static/edu/program/js/outline.js"></script>
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
  .doc-table{
    font-size:10.5pt;
    width: 100%;
    text-align:center;
    table-layout: fixed;
    border-collapse: collapse;
  }
  .doc-table tr {
    word-wrap: break-word;
  }
  .doc-table td, .doc-table th {
    border: 0.5px solid black;
    overflow: hidden;
  }
  </style>
[#assign maxTerm = plan.terms /]
[#assign displayCourseEnName=true/]

<header>
  <nav class="navbar navbar-expand-lg navbar-light bg-light">
    [@b.a href="!info?id="+program.id class="navbar-brand"]${program.grade.code}级 ${program.level.name} ${program.department.name} ${program.major.name}  ${(program.direction.name)!} 专业培养方案[/@]
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
          [#include "/org/openurp/edu/program/web/components/info/docinfo.ftl"/]
        [/#if]
        <div style="margin-top:20px;">
          <h1>
            <a class="q-anchor q-heading-anchor" name="九、专业教学计划表（附表）"></a>九、专业教学计划表（附表）
          </h1>
        </div>
        [#include "/org/openurp/edu/program/web/components/info/planinfo.ftl"/]
      </div>
    </article>
  </main>
  <aside id="page-right-aside">
    <div id="toolboxes">
     [#include "/org/openurp/edu/program/web/components/info/tags.ftl"/]
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
