[@b.head/]
  [@b.form name="uploadForm"  action="!upload" theme="list"]
    [@b.file name="img" extends="file" label="上传图片" required="true" extensions="png"/]
    [@b.formfoot]
      <input type="hidden" name="program.id" value="${program.id}"/>
      [@b.submit value="上传"/]
    [/@]
  [/@]
[@b.foot/]
