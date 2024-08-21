package org.openurp.edu.program.web.action.alt

import org.beangle.commons.collection.{Collections, Order}
import org.beangle.data.dao.OqlBuilder
import org.beangle.security.Securities
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.model.User
import org.openurp.edu.grade.model.CourseGrade
import org.openurp.edu.program.flow.CourseTypeChangeApply
import org.openurp.starter.web.support.ProjectSupport

class CourseTypeAction extends RestfulAction[CourseTypeChangeApply], ProjectSupport {

  override def search(): View = {
    val builder = OqlBuilder.from(classOf[CourseTypeChangeApply], "apply")
    val orderBy = get(Order.OrderStr, "apply.updatedAt desc")
    populateConditions(builder)
    builder.orderBy(orderBy)
    builder.limit(getPageLimit)
    put("applies", entityDao.search(builder))
    forward()
  }

  def audit(): View = {
    val ids = getLongIds("apply")
    val approved = getBoolean("approved", false)
    val reply = get("reply")
    val applies = entityDao.find(classOf[CourseTypeChangeApply], ids)
    val grades = Collections.newBuffer[CourseGrade]
    val me = entityDao.findBy(classOf[User], "code", Securities.user).head
    for (apply <- applies) {
      val query: OqlBuilder[CourseGrade] = OqlBuilder.from(classOf[CourseGrade], "cg")
      query.where("cg.std=:std and cg.course=:course", apply.std, apply.course)
      val gs = entityDao.search(query)
      apply.approve(approved, me, reply)
      if (approved) {
        gs foreach { g => g.courseType = apply.newType }
      } else {
        gs foreach { g => g.courseType = apply.oldType }
      }
      grades.addAll(gs)
    }
    entityDao.saveOrUpdate(grades, applies)
    redirect("search", "info.save.success")
  }
}
