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

package org.openurp.edu.program.service.lixin

import org.beangle.commons.collection.Collections
import org.openurp.edu.program.model.MajorPlan
import org.openurp.edu.program.service.PlanChecker

/** 长学段不能开始1学分的课程
 */
class StagePlanChecker extends PlanChecker {

  var excludeCourseNames: Set[String] = Set("诚信教育", "心理健康①", "心理健康②", "大学信息技术", "体育(一)", "体育(二)",
    "心理健康",
    "体育(三)", "体育(四)", "职业规划与就业指导①", "职业规划与就业指导②", "劳动教育与实践（一）", "劳动教育与实践（二）",
    "形势与政策", "形势与政策①", "形势与政策②", "形势与政策③", "形势与政策④", "形势与政策⑤", "形势与政策⑥", "形势与政策⑦", "形势与政策⑧",
    "马克思主义基本原理实践", "英语口语与写作（一）", "英语口语与写作（二）", "英语口语与写作（三）", "英语口语与写作（四）",
    "思想道德与法治实践", "会计基础实验", "职业规划与就业指导", "中国近现代史纲要实践", "马克思主义基本原理概论实践",
    "国家安全教育", "信息技术与AI素养",
    //特别学院的，特别课程
    "学术论文写作技巧", "统计软件应用", "企业并购与合并报表系列实验", "学术论文写作技巧",
    "研究基础(一)", "研究基础(二)"
  )

  override def check(plan: MajorPlan): Seq[String] = {
    val rs = Collections.newBuffer[String]
    plan.groups foreach { g =>
      if (g.stage.nonEmpty && g.stage.get.name.contains("长学段")) {
        g.planCourses foreach { pc =>
          if (!excludeCourseNames.contains(pc.course.name) &&
            !pc.course.name.endsWith("专业引导") &&
            !pc.course.name.contains("新生研讨课") &&
            !pc.course.name.contains("新生导学课")) {
            if (pc.course.defaultCredits.toInt < 2) {
              rs.addOne(s"长学段不能安排1学分的课程:${pc.course.name} ${pc.course.defaultCredits}学分 ${pc.journal.creditHours}学时")
            }
          }
        }
      }
    }
    rs.toSeq
  }

}
