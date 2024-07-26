          [@b.form theme="list" action="!saveApproach" target="_self" name="form${text.id}"]
            [@b.textfield label="顺序号" name="index"  required="true" value=text.name?substring(text.name?index_of('.')+1) maxlength="100"/]
            [@b.textfield label="标题" name="text.title"  required="true" value=text.title! maxlength="100"/]
            [@b.textarea label="内容" name="text.contents" rows="9" cols="80" value=text.contents! required="true" maxlength="1000"]
              <a class="btn btn-sm btn-outline-primary" onclick="return toggleTable(this)">
                [#if text.linkTable??]<i class="fa fa-minus"></i>附加表格[#else]<i class="fa fa-plus"></i>附加表格[/#if]
              </a>
            [/@]
            [@b.editor theme="mini" name="${text.name}.table" label="附加表格" rows="7" cols="80" style="width:650px;heigth:300px;" maxlength="20000" value=(table.contents)! /]
            [@b.formfoot]
              <input type="hidden" name="doc.id" value="${doc.id}"/>
              <input type="hidden" name="text.id" value="${text.id}"/>
              <input type="hidden" name="hasTable" value="${(text.linkTable??)?string('1','0')}"/>
              <input type="hidden" name="text.name" value="${text.name}"/>
              [@b.submit value="保存" /]
            [/@]
          [/@]
          <script>
            function toggleTable(elem){
              var scoreLi = elem.parentNode.nextElementSibling;
              if(scoreLi.style.display=="none"){
                scoreLi.style.display=""
                elem.innerHTML="<i class='fa fa-minus'></i>附加表格";
                form${text.id}['hasTable'].value="1";
              }else{
                scoreLi.style.display="none";
                elem.innerHTML="<i class='fa fa-plus'></i>附加表格";
                form${text.id}['hasTable'].value="0";
                scoreLi.querySelectorAll("textarea").forEach(function(x) {x.value="";})
                var i=0;
                var cnNodes= elem.childNodes;
                while(i < cnNodes.length){
                  if(cnNodes[i].tagName=="TEXTAREA"){
                    cnNodes[i].value="";
                    break;
                  }
                  i+=1;
                }
              }
            }
          </script>
