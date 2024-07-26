[@b.div id="div_topic_${approach.id}"]
  <div class="card card-info card-primary card-outline">
      [@b.card_header]
        <div class="card-title">${approach.title!}
        </div>
        [@b.card_tools]
         <div class="btn-group">
         [@b.a href="!editApproach?approach.id=${approach.id}" class="btn btn-sm btn-outline-info"]<i class="fa fa-edit"></i>修改[/@]
         [@b.a href="!removeApproach?approach.id=${approach.id}" onclick="return confirm('确定删除该内容?');" class="btn btn-sm btn-outline-danger"]<i class="fa fa-xmark"></i>删除[/@]
         </div>
        [/@]
       [/@]
      <div class="card-body">
        <p style="white-space: preserve;">${approach.contents}</p>
        [#if approach.linkTable??]
        ${(doc.getTable(approach.linkTable).contents)!}
        [/#if]
      </div>
  </div>
[/@]
