package org.openurp.edu.program.alternative.web.helper

import org.beangle.commons.lang.Strings
import org.beangle.data.dao.{EntityDao, OqlBuilder}
import org.beangle.data.transfer.importer.{ImportListener, ImportResult}
import org.openurp.base.edu.model.{Course, Project, Student}
import org.openurp.edu.program.model.StdAlternativeCourse

import java.time.Instant
import scala.collection.mutable

class StdAlternativeCourseImportListener(entityDao: EntityDao, project: Project) extends ImportListener {
  override def onStart(tr: ImportResult): Unit = {}

  override def onFinish(tr: ImportResult): Unit = {}

  override def onItemStart(tr: ImportResult): Unit = {}

  override def onItemFinish(tr: ImportResult): Unit = {
    transfer.curData.get("stdCode") foreach { stdCode =>
      val query = OqlBuilder.from(classOf[Student], "s")
      query.where("s.project=:project and s.user.code=:code", project, stdCode)
      val stds = entityDao.search(query)
      val sc = new StdAlternativeCourse
      sc.std = stds.head
      fillCourse(sc.olds, transfer.curData.getOrElse("oldCourse", "").toString)
      fillCourse(sc.news, transfer.curData.getOrElse("newCourse", "").toString)

      if (sc.olds.isEmpty) {
        tr.addFailure("找不到原课程", stdCode)
      } else if (sc.news.isEmpty) {
        tr.addFailure("找不到替代课程", stdCode)
      } else {
        val builder = OqlBuilder.from(classOf[StdAlternativeCourse],
          "stdAlternativeCourse")
        builder.where("stdAlternativeCourse.std.id=:stdId", sc.std.id)
          .where("stdAlternativeCourse.std.project = :project", project)
        val stdAlternativeCourses = entityDao.search(builder)
        val existed = stdAlternativeCourses.exists(st => st.olds == sc.olds && st.news == sc.news)
        if (existed) {
          tr.addFailure("原课程-替代课程关系已经存在", stdCode + " " + sc.olds.head.code + " " + sc.news.head.code)
        } else {
          sc.updatedAt = Instant.now
          sc.remark = Some("前台导入")
          entityDao.saveOrUpdate(sc)
        }
      }
    }
  }

  private def fillCourse(courses: mutable.Set[Course], courseCodeSeq: String): Unit = {
    val codeName = if (courseCodeSeq.contains(" ")) {
      Strings.substringBefore(courseCodeSeq, " ")
    } else {
      courseCodeSeq
    }
    val courseCodes = Strings.split(codeName, ",")
    courses.clear()
    if (courseCodes != null) {
      for (code <- courseCodes) {
        val finded = entityDao.search(OqlBuilder.from(classOf[Course], "c").where("c.project=:project and c.code=:code", project, code))
        courses.addAll(finded)
      }
    }
  }
}

