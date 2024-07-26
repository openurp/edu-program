<style>
  .tag-group{
    margin-bottom: 4px;
    border-bottom: 0.0625rem solid lightgray;
    min-height: 1.625rem;
    font-weight: bold;
  }
</style>
  <div class="page-body-module" style="overflow-y: scroll;max-height: 800px;">
    [#list tags as tag]
    <div class="tag-group"><i class="fa-solid fa-tags"></i> ${tag.name}</div>
    <div>
       <ol id="tag_${tag.id}_courses" style="padding-left:2rem;margin-bottom:4px;">
       [#list program.labels as l]
         [#if l.tag == tag]<li>${l.course.name}</li>[/#if]
       [/#list]
       </ol>
    </div>
    [/#list]
    [#assign taggedCourses = {}/]
    [#list plan.groups as g]
      [#list g.planCourses as pc]
        [#list pc.course.tags as t]
          [#assign taggedCourses = taggedCourses+{t.name:([pc.course]+(taggedCourses[t.name])![])}/]
        [/#list]
      [/#list]
    [/#list]
    [#list taggedCourses?keys?sort as tag]
    <div class="tag-group"><i class="fa-solid fa-tags"></i> ${tag}</div>
    <div>
       <ol style="padding-left:2rem;margin-bottom:0px;">
       [#list taggedCourses[tag] as c]
          <li>${c.name}</li>
       [/#list]
       </ol>
    </div>
    [/#list]
  </div>
