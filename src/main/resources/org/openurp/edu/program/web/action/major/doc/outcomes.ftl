[#ftl]
[@b.head/]
<div class="container">
[@b.toolbar title="教学培养方案修订"]
  bar.addClose();
[/@]
[#include "step.ftl"/]
[@displayStep 1/]
<div class="border-colored border-1px border-0px-tb" style="margin-bottom:20px">
  [@b.form theme="list" action="!saveOutcomes1"]
    [#list 1..12 as i]
    [@b.textfield name="R${i}"  label="毕业要求R${i}" value=(docObjectives[i-1])! maxlength="20"/]
    [/#list]
    [@b.formfoot]
      <input type="hidden" name="id" value="${doc.id}"/>
      <input type="hidden" name="step" value="outcomes2"/>
      [@b.a href="!edit?id=${doc.id}" class="btn btn-outline-primary btn-sm" ]<i class="fa fa-arrow-circle-left fa-sm"></i>上一步[/@]
      [@b.submit value="保存，进入下一步" /]
    [/@]
  [/@]
  </div>
  <script>
    function overCell(cell){
      cell.style.backgroundColor="#f0f0f0";
    }
    function outCell(cell){
      cell.style.backgroundColor="";
    }
    function toggleCell(cell){
      var id = cell.id;
      var underscoreIdx= id.indexOf("_")
      var goId=id.substring(0,underscoreIdx)
      var coCode=id.substring(underscoreIdx+1)
      var hv = document.getElementById("GO"+goId+".courseObjectives");
      if(cell.innerHTML=="\u2714"){
        cell.innerHTML="";
        hv.value = hv.value.replace(coCode,"");
        hv.value = hv.value.replace(",,",",");
      }else{
        cell.innerHTML="&#10004";
        hv.value = (hv.value + "," + coCode);
      }
    }
  </script>
</div>
[@b.foot/]
