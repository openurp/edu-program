/*
 * Copyright (C) 2014, The OpenURP Software.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.openurp.edu.program.web.action.alt

import org.beangle.commons.collection.{Collections, Order}
import org.beangle.commons.lang.Strings
import org.beangle.data.dao.OqlBuilder
import org.beangle.ems.app.Ems
import org.beangle.security.Securities
import org.beangle.webmvc.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.model.User
import org.openurp.edu.program.flow.CourseAlternativeApply
import org.openurp.edu.program.model.StdAlternativeCourse
import org.openurp.starter.web.support.ProjectSupport

class ApplyAction extends RestfulAction[CourseAlternativeApply], ProjectSupport {

  override protected def simpleEntityName: String = "apply"

  override def search(): View = {
    val builder = OqlBuilder.from(classOf[CourseAlternativeApply], "apply")
    val orderBy = get(Order.OrderStr, "apply.updatedAt desc")
    val oldCourse = get("oldCourse", "")
    val newCourse = get("newCourse", "")
    if (Strings.isNotEmpty(oldCourse)) {
      builder.where("exists(from apply.olds as o where o.code like :term or o.name like :term)", "%" + oldCourse + "%")
    }
    if (Strings.isNotEmpty(newCourse)) {
      builder.where("exists(from apply.news as o where o.code like :term or o.name like :term)", "%" + newCourse + "%")
    }
    populateConditions(builder)
    builder.limit(getPageLimit)
    builder.orderBy(orderBy)
    put("ems_base", Ems.base)
    put("applies", entityDao.search(builder))
    forward()
  }

  def audit(): View = {
    val ids = getLongIds("apply")
    val approved = getBoolean("approved", false)
    val applies = entityDao.find(classOf[CourseAlternativeApply], ids)
    val sacs = Collections.newBuffer[StdAlternativeCourse]
    val removed = Collections.newBuffer[StdAlternativeCourse]
    val me = entityDao.findBy(classOf[User], "code", Securities.user).head
    val reply = get("reply")
    for (apply <- applies) {
      apply.approve(approved, me, reply)
      if (approved) {
        val stdAc = new StdAlternativeCourse(apply.std)
        stdAc.update(apply.olds, apply.news)
        stdAc.remark = Some("学生申请")
        sacs.addOne(stdAc)
      } else {
        val acBuilder = OqlBuilder.from(classOf[StdAlternativeCourse], "ac").where("ac.std=:std", apply.std)
        val acs = entityDao.search(acBuilder)
        for (ac <- acs) {
          if (ac.olds == apply.olds && ac.news == apply.news) {
            removed.addOne(ac)
          }
        }
      }
    }
    entityDao.remove(removed)
    entityDao.saveOrUpdate(sacs, applies)
    redirect("search", "info.save.success")
  }
}
