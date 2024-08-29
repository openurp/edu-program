<div class="card card-info card-outline">
  <div class="card-header">
    <h2 class="card-title">${depart.name} 自主开课与交叉开课明细</h2>
  </div>
  <div class="card-body" style="padding-top: 0px;">
    [@b.tabs]
      [@b.tab label="自主开课(${coursesOwn?size})"]
        [#include "coursesOwn.ftl"/]
      [/@]
      [@b.tab label="其他院系开课(${coursesOther?size})"]
        [#include "coursesOther.ftl"/]
      [/@]
      [@b.tab label="为其他院系开课(${coursesForOther?size})"]
        [#include "coursesForOther.ftl"/]
      [/@]
    [/@]
  </div>
  <div class="modal fade" id="courseListDialog" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="course_detail_title">课程信息</h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body" style="padding-top: 0px;">
         <div id='courseListDiv' style="overflow-y:scroll;max-height:600px;"></div>
        </div>
      </div>
    </div>
  </div>
  <script>
     function displayCourses(courseId,programIds){
       bg.Go('${b.url("!courseDetails")}?course.id='+courseId+"&programIds="+programIds,"courseListDiv");
       jQuery("#courseListDialog").modal('show');
       return false;
     }
  </script>
</div>
