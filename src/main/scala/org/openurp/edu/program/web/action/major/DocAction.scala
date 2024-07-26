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

package org.openurp.edu.program.web.action.major

import org.beangle.commons.lang.Strings
import org.beangle.data.dao.EntityDao
import org.beangle.web.action.support.ActionSupport
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.EntityAction
import org.openurp.edu.program.model.*
import org.openurp.starter.web.support.ProjectSupport

import java.time.Instant
import java.util.Locale

/** 方案文本编辑
 */
class DocAction extends ActionSupport, EntityAction[ProgramDoc], ProjectSupport {

  var entityDao: EntityDao = _

  def edit(): View = {
    var doc: ProgramDoc = null
    getLong("id") match {
      case None =>
        val program = entityDao.get(classOf[Program], getLongId("program"))
        entityDao.findBy(classOf[ProgramDoc], "program", program).headOption match
          case None =>
            doc = new ProgramDoc
            doc.program = program
            doc.docLocale = Locale.SIMPLIFIED_CHINESE
            doc.updatedAt = Instant.now
            entityDao.saveOrUpdate(doc)
          case Some(d) => doc = d
      case Some(id) =>
        doc = entityDao.get(classOf[ProgramDoc], id)
    }
    put("doc", doc)
    if (get("step", "").startsWith("outcomes")) {
      put("docObjectives", doc.outcomes.sortBy(_.idx).map(_.title))
    }
    get("step") match
      case None => forward("form")
      case Some(s) => forward(s"${s}")
  }

  def saveObjectives(): View = {
    val doc = entityDao.get(classOf[ProgramDoc], getLongId("doc"))
    doc.updatedAt = Instant.now

    val summary = cleanText(get("summary", ""))
    doc.getText("summary") match
      case Some(txt) =>
        if Strings.isBlank(summary) then doc.texts.subtractOne(txt)
        else txt.contents = summary
      case None =>
        if Strings.isNotBlank(summary) then doc.texts.addOne(new ProgramText(doc, "summary", "概述", summary))

    val titles = List("人才培养目标", "人才培养特色")
    titles.indices foreach { i =>
      val name = s"goals.${i + 1}"
      doc.getText(name) match
        case Some(values) => values.contents = get(name, "--")
        case None =>
          val v = new ProgramText(doc, name, titles(i), get(name, "--"))
          doc.texts.addOne(v)
    }

    (1 to 8) foreach { i =>
      val code = s"G${i}"
      val contents = get(code, "")
      doc.getObjective(code) match {
        case None =>
          if Strings.isNotBlank(contents) then
            val o = new ProgramObjective(doc, code, contents)
            o.outcomes = "--"
            doc.objectives += o
        case Some(o) =>
          if Strings.isBlank(contents) then doc.objectives -= o
          else o.contents = contents
      }
    }
    entityDao.saveOrUpdate(doc)
    toStep(doc)
  }

  def saveOutcomes1(): View = {
    val doc = entityDao.get(classOf[ProgramDoc], getLongId("doc"))
    (1 to 12) foreach { idx =>
      val name = get(s"R${idx}", "")
      if (Strings.isNotEmpty(name)) {
        doc.outcomes.find(_.idx == idx) match
          case None =>
            val g = new ProgramOutcome(doc, idx, name, " ")
            doc.outcomes.addOne(g)
          case Some(outcome) => outcome.title = name
      } else {
        doc.outcomes.find(_.idx == idx) foreach {
          doc.outcomes.subtractOne
        }
      }
    }
    var idx = 1
    doc.outcomes.sortBy(_.idx) foreach { o =>
      o.idx = idx
      idx += 1
    }
    doc.outcomes.subtractAll(doc.outcomes.filter(_.idx > 12))
    entityDao.saveOrUpdate(doc)
    toStep(doc)
  }

  def saveOutcomes(): View = {
    val doc = entityDao.get(classOf[ProgramDoc], getLongId("doc"))

    val outcomes = cleanText(get("outcomes", ""))
    doc.getText("outcomes") match
      case Some(txt) =>
        if Strings.isBlank(outcomes) then doc.texts.subtractOne(txt)
        else txt.contents = outcomes
      case None =>
        if Strings.isNotBlank(outcomes) then doc.texts.addOne(new ProgramText(doc, "outcomes", "毕业要求概述", outcomes))

    doc.outcomes foreach { outcome =>
      outcome.contents = get(s"${outcome.code}.contents", "--")
    }
    doc.objectives foreach { o =>
      var outcomeCodes = get(s"G${o.id}.outcomes", "")
      outcomeCodes = Strings.split(Strings.replace(outcomeCodes, "--", "")).sorted.mkString(",")
      if (Strings.isEmpty(outcomeCodes)) outcomeCodes = "--"
      o.outcomes = outcomeCodes
    }
    entityDao.saveOrUpdate(doc)
    toStep(doc)
  }

  /** 保存学分和学制
   *
   * @return
   */
  def saveCredits(): View = {
    val doc = entityDao.get(classOf[ProgramDoc], getLongId("doc"))
    doc.updatedAt = Instant.now

    val titles = List("学制和最低学分要求", "主要课程")
    val names = List("credits", "courses")
    names.indices foreach { i =>
      val name = names(i)
      doc.getText(name) match
        case Some(values) => values.contents = get(name, "--")
        case None =>
          val v = new ProgramText(doc, name, titles(i), get(name, "--"))
          doc.texts.addOne(v)
    }
    entityDao.saveOrUpdate(doc)
    toStep(doc)
  }

  /** 保存courses对毕业要求达成矩阵
   *
   * @return
   */
  def saveCourses(): View = {
    val doc = entityDao.get(classOf[ProgramDoc], getLongId("doc"))
    doc.updatedAt = Instant.now

    val titles = List("课程设置与毕业要求达成关系矩阵")
    val names = List("courseOutcome")
    names.indices foreach { i =>
      val name = names(i)
      doc.getTable(name) match
        case Some(values) => values.contents = get(name, "--")
        case None =>
          val v = new ProgramTable(doc, name, titles(i), get(name, "--"))
          doc.tables.addOne(v)
    }
    entityDao.saveOrUpdate(doc)
    toStep(doc)
  }

  /** 保存转专业
   *
   * @return
   */
  def saveTransfer(): View = {
    val doc = entityDao.get(classOf[ProgramDoc], getLongId("doc"))
    doc.updatedAt = Instant.now

    val titles = List("转专业")
    val names = List("transfer")
    names.indices foreach { i =>
      val name = names(i)
      doc.getText(name) match
        case Some(values) => values.contents = get(name, "--")
        case None =>
          val v = new ProgramText(doc, name, titles(i), get(name, "--"))
          doc.texts.addOne(v)
    }
    entityDao.saveOrUpdate(doc)
    toStep(doc)
  }

  /** 保存培养路径
   *
   * @return
   */
  def saveApproach0(): View = {
    val doc = entityDao.get(classOf[ProgramDoc], getLongId("doc"))
    doc.updatedAt = Instant.now

    val titles = List("专业人才培养路径")
    val names = List("approach")
    names.indices foreach { i =>
      val name = names(i)
      doc.getText(name) match
        case Some(values) => values.contents = get(name, "--")
        case None =>
          val v = new ProgramText(doc, name, titles(i), get(name, "--"))
          doc.texts.addOne(v)
    }
    entityDao.saveOrUpdate(doc)
    redirect("edit", s"id=${doc.id}&step=approaches", "info.save.success")
  }

  /** 保存培养路径
   *
   * @return
   */
  def saveApproach(): View = {
    val doc = entityDao.get(classOf[ProgramDoc], getLongId("doc"))
    doc.updatedAt = Instant.now

    val text = populateEntity(classOf[ProgramText], "text")
    if (getBoolean("hasTable", false)) {
      val tabCaption = "学院推荐学生在读期间考取的证书"
      val tabname = text.name + ".table"
      doc.getTable(tabname) match
        case Some(values) => values.contents = get(tabname, "--")
        case None =>
          val v = new ProgramTable(doc, tabname, tabCaption, get(tabname, "--"))
          doc.tables.addOne(v)
      text.linkTable = Some(tabname)
    } else {
      text.linkTable foreach { linkTable =>
        doc.tables.subtractAll(doc.tables.find(_.name == linkTable))
      }
    }
    if (!text.persisted) {
      text.doc = doc
      doc.texts.addOne(text)
    }
    entityDao.saveOrUpdate(doc)
    redirect("edit", s"id=${doc.id}&step=approaches", "info.save.success")
  }

  def editApproach(): View = {
    val text = entityDao.get(classOf[ProgramText], getLongId("approach"))
    if (text.linkTable.nonEmpty) {
      val table = text.doc.tables find (x => text.linkTable.contains(x.name))
      put("table", table)
    }
    put("text", text)
    put("doc", text.doc)
    forward()
  }

  /** 删除培养路径
   *
   * @return
   */
  def removeApproach(): View = {
    val text = entityDao.get(classOf[ProgramText], getLongId("approach"))
    val doc = text.doc
    text.linkTable foreach { link =>
      doc.tables.subtractAll(doc.tables.find(_.name == link))
    }
    doc.texts.subtractOne(text)
    entityDao.saveOrUpdate(doc)
    redirect("edit", s"id=${doc.id}&step=approaches", "info.remove.success")
  }

  private def toStep(doc: ProgramDoc): View = {
    get("step") match
      case None => redirect("info", "info.save.success")
      case Some(s) => redirect("edit", s"id=${doc.id}&step=${s}", "info.save.success")
  }

  private def cleanText(contents: String): String = {
    var c = Strings.replace(contents, "\r", "")
    c = Strings.replace(c, "\n", "")
    c
  }

}
