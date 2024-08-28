[#ftl]
[@b.head/]
[@b.grid items=plans var="plan"]
    [@b.gridbar]
        bar.addItem("新增",action.add());
        bar.addItem("修改",action.edit());
        bar.addItem("删除",action.remove());
        bar.addItem("复制",action.single("copy"));
        bar.addItem("课程设置","groupList()");
    [/@]
    [@b.row]
        [@b.boxcol width="5%"/]
        [@b.col property="fromGrade" title="年级" width="13%"]
          [#if plan.fromGrade == plan.toGrade]${plan.fromGrade}[#else]${plan.fromGrade}~${plan.toGrade}[/#if]
        [/@]
        [@b.col property="name" title="名称" width="32%"]
            [@b.a target="_blank" href="!info?id=${plan.id}"]${(plan.name)?default("")}[/@]
        [/@]
        [@b.col property="level.name" title="培养层次" width="20%"]
            ${plan.level.name}
        [/@]
        [@b.col property="beginOn" title="生效日期" width="15%"/]
        [@b.col property="endOn" title="失效日期" width="15%"/]
    [/@]
[/@]

<script language="javascript">
    var form = document.searchForm;
       function dataout(){
          var id = bg.input.getCheckBoxValues("plan.id");
          if(id==""||id.indexOf(",")>0){
            alert("请选择一项");
            return;
          }
          bg.form.addInput(form,"shareCourseGroup.plan.id",id);
          form.target='_self';
           bg.form.addInput(form,"planId",id);
           bg.form.addInput(form, "template", "template/excel/plan.xls", "hidden");
           bg.form.submit("searchForm","${b.base}/plan!export.action",null,null,false);
           form.action="plan!search.action";
           form.target="contentDiv";
       }

       function groupList(){
        var id = bg.input.getCheckBoxValues("plan.id");
          if(id==""||id.indexOf(",")>0){
            alert("请选择一项");
            return;
        }
          form.target='_blank';
          bg.form.submit("searchForm","${b.base}/plan!groupList.action?plan.id="+id);
          form.target="contentDiv";
          form.action="plan!search.action";
       }

       function gradeAuthentication(grade){
           if(parseInt(grade)==grade && eval("'"+parseInt(grade)+"'.length")==grade.length && grade.length==4){
               return true;
           }else{
               return false;
           }
       }
 </script>
[@b.foot/]
