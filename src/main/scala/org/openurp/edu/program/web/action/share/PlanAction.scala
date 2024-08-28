package org.openurp.edu.program.web.action.share

import org.beangle.data.dao.OqlBuilder
import org.beangle.web.action.view.View
import org.beangle.webmvc.support.action.RestfulAction
import org.openurp.base.std.model.Grade
import org.openurp.edu.program.model.SharePlan
import org.openurp.starter.web.support.ProjectSupport

import java.time.Instant

class PlanAction extends RestfulAction[SharePlan], ProjectSupport {

  override protected def simpleEntityName: String = "plan"

  override protected def indexSetting(): Unit = {
    val project = getProject
    put("levels", project.levels)
  }

  override protected def editSetting(entity: SharePlan): Unit = {
    super.editSetting(entity)
    val project = getProject
    put("levels", project.levels)
    val query = OqlBuilder.from(classOf[Grade], "g")
    query.where("g.project=:project", project)
    query.orderBy("g.code desc")
    put("grades", entityDao.search(query))
    put("project", project)
  }

  override protected def getQueryBuilder: OqlBuilder[SharePlan] = {
    val query = super.getQueryBuilder
    query.where("plan.project=:project", getProject)
    query
  }

  override protected def saveAndRedirect(plan: SharePlan): View = {
    plan.updatedAt = Instant.now
    plan.project = getProject
    super.saveAndRedirect(plan)
  }
}
