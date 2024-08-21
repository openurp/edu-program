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
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.edu.model.{Course, Direction, Major}
import org.openurp.base.model.Project
import org.openurp.base.std.model.Grade
import org.openurp.edu.program.model.MajorAlternativeCourse
import org.openurp.starter.web.support.ProjectSupport

import java.time.Instant

/** 专业替代课程
 */
class MajorAction extends RestfulAction[MajorAlternativeCourse], ProjectSupport {

  override protected def simpleEntityName: String = "alt"

  override protected def indexSetting(): Unit = {
    given project: Project = getProject

    put("project", project)
    put("departs", getDeparts)

    put("majors", findInProject(classOf[Major]))
    put("directions", findInProject(classOf[Direction]))
    super.indexSetting()
  }

  override protected def getQueryBuilder: OqlBuilder[MajorAlternativeCourse] = {
    val builder = OqlBuilder.from(classOf[MajorAlternativeCourse], "alt")
    populateConditions(builder)
    val oldCode = get("oldCode", "").trim().replaceAll("'", "")
    val oldName = get("oldName", "").trim().replaceAll("'", "")
    val newCode = get("newCode", "").trim().replaceAll("'", "")
    val newName = get("newName", "").trim().replaceAll("'", "")
    if (Strings.isNotEmpty(oldCode)) builder.where("exists(from alt.olds o where o.code like '%" + oldCode + "%')")
    if (Strings.isNotEmpty(oldName)) builder.where("exists(from alt.olds o where o.name like '%" + oldName + "%')")
    if (Strings.isNotEmpty(newCode)) builder.where("exists(from alt.news n where n.code like '%" + newCode + "%')")
    if (Strings.isNotEmpty(newName)) builder.where("exists(from alt.news n where n.name like '%" + newName + "%')")
    if (Strings.isBlank(get(Order.OrderStr, ""))) builder.orderBy("alt.fromGrade.code desc")
    else builder.orderBy(get(Order.OrderStr, ""))
    builder.limit(getPageLimit)
    builder.tailOrder("alt.id")
  }

  override protected def editSetting(alt: MajorAlternativeCourse): Unit = {
    given project: Project = getProject

    put("project", project)
    put("departs", getDeparts)

    put("majors", findInProject(classOf[Major]))
    put("directions", findInProject(classOf[Direction]))
  }

  override def saveAndRedirect(alt: MajorAlternativeCourse): View = {
    val project = getProject
    val olds = entityDao.find(classOf[Course], getLongIds("old"))
    val news = entityDao.find(classOf[Course], getLongIds("new"))
    alt.olds.clear()
    alt.olds.addAll(olds)
    alt.news.clear()
    alt.news.addAll(news)

    alt.fromGrade = entityDao.get(classOf[Grade], alt.fromGrade.id)
    alt.toGrade = entityDao.get(classOf[Grade], alt.toGrade.id)
    if (alt.olds.isEmpty || alt.news.isEmpty) {
      editSetting(alt)
      addMessage(getText("info.save.failure"))
      put("alt", alt)
      forward("form")
    } else {
      val q = OqlBuilder.from(classOf[MajorAlternativeCourse], "alt")
      q
        .where("alt.fromGrade.code <=:toGrade and alt.toGrade.code >= :fromGrade", alt.toGrade.code, alt.fromGrade.code)
        .where("alt.project=:project", alt.project)
      if alt.persisted then q.where("alt.id != :altId", alt.id)
      alt.department match
        case None => q.where("alt.department is null")
        case Some(d) => q.where("alt.department=:department", d)

      alt.stdType match
        case None => q.where("alt.stdType.id is null")
        case Some(s) => q.where("alt.stdType=:stdType", s)

      alt.major match
        case None => q.where("alt.major is null")
        case Some(m) => q.where("alt.major=:major", m)

      alt.direction match
        case None => q.where("alt.direction is null")
        case Some(d) => q.where("alt.direction=:direction", d)

      val exists = entityDao.search(q)
      if (exists.exists(x => x.olds == alt.olds && x.news == alt.news)) {
        redirect("search", "该替代课程组合已存在!")
      } else if (Collections.intersection(alt.olds, alt.news).nonEmpty) {
        redirect("search", "原课程与替代课程一样!")
      } else {
        alt.updatedAt = Instant.now
        entityDao.saveOrUpdate(alt)
        redirect("search", "info.save.success")
      }
    }
  }
}
