[@b.head/]
<div class="container-fluid">
  [@b.toolbar title="培养方案查询"]
    bar.addBack();
  [/@]
  <nav class="navbar navbar-expand-lg navbar-light bg-white">
    <a class="navbar-brand" style="font-size: 1rem;">专业培养方案信息查询</a>
    <ul class="navbar-nav mr-auto">
      <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-expanded="false">
          ${grade.name}
        </a>
        <div class="dropdown-menu">
          [#list grades as g]
          [@b.a class="dropdown-item" href="!index?grade.id="+g.id]${g.name}[/@]
          [/#list]
        </div>
      </li>
    </ul>
  </nav>
  <div class="row">
     <div class="col-2" id="accordion">
       <div class="card card-info card-outline">
         <div class="card-header" id="stat_header_1">
           <h5 class="mb-0">
              <button class="btn btn-link" data-toggle="collapse" data-target="#stat_body_2" aria-expanded="true" aria-controls="stat_body_1" style="padding: 0;">
                院系统计
              </button>
            [#assign total=0]
            [#list departStats as s]
            [#assign total=total+s[2]]
            [/#list]
            <span style="float: right;font-size: 0.75rem;" class="badge badge-primary">${total}</span>
           </h5>
         </div>
         <div id="stat_body_2" class="collapse show" aria-labelledby="stat_header_1" data-parent="#accordion">
           <div class="card-body" style="padding-top: 0px;max-height:600px;overflow:scroll;">
             <table class="table table-hover table-sm">
               <tbody>
               [#list departStats as stat]
                <tr>
                 <td width="80%">[@b.a href="!programs?department.id="+stat[0]+"&grade.id=${grade.id}" target="content_list"]${stat[1]}[/@]</td>
                 <td width="20%">${stat[2]}</td>
                </tr>
                [/#list]
               </tbody>
             </table>
           </div>
         </div>
       </div>

     [#--
       <div class="card card-info card-primary card-outline">
         <div class="card-header" id="stat_header_1">
          <h5 class="mb-0">
              <button class="btn btn-link" data-toggle="collapse" data-target="#stat_body_2" aria-expanded="true" aria-controls="stat_body_1" style="padding: 0;">
                课程标签
              </button>
            </h5>
         </div>
         <div id="stat_body_2" class="collapse show" aria-labelledby="stat_header_1" data-parent="#accordion">
           <div class="card-body" style="padding-top: 0px;max-height:400px;overflow:scroll;">
             <table class="table table-hover table-sm">
               <tbody>
               [#list tagStat as stat]
                <tr>
                 <td width="80%">[@b.a href="!search?tag.id="+stat[0] target="content_list"]${stat[1]}[/@]</td>
                 <td width="20%">${stat[2]}</td>
                </tr>
                [/#list]
               </tbody>
             </table>
           </div>
         </div>
       </div>
       --]

     </div><!--end col-3-->
     [@b.div class="col-10" id="content_list" href="!programs?department.id="+departStats?first[0]+"&grade.id=${grade.id}"/]
  </div><!--end row-->
</div><!--end container-->
[@b.foot/]
