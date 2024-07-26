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

package org.openurp.edu.program.service.impl

import org.beangle.commons.collection.Collections
import org.beangle.commons.lang.Strings
import org.languagetool.{JLanguageTool, Languages}
import org.openurp.base.edu.model.CourseJournal

/** 课程英文名
 */
class EnNameChecker {
  val preps = Set("of", "for", "a", "an", "with", "on", "in", "at")
  val symbols = Set('(', '&', '"')
  private val lang = Languages.getLanguageForShortCode("en-US")
  private val msgs = Map("It appears that a white space is missing." -> "少一个空格",
    "Possible spelling mistake found." -> "有可能拼写错误",
    "It seems like there are too many consecutive spaces here." -> "连续空格",
    "Possible typo: you repeated a whitespace" -> "连续空格",
    "Don't put a space after the opening parenthesis." -> "括弧后不要放空格")

  def check(journals: Iterable[CourseJournal]): Map[CourseJournal, String] = {
    val rs = Collections.newMap[CourseJournal, String]
    journals foreach { journal =>
      journal.enName match
        case None => rs.put(journal, "缺少英文名")
        case Some(enName) =>
          val formatOK = isFormatCorrect(enName)
          if (!formatOK._1) {
            rs.put(journal, s"格式错误:${formatOK._2}")
          } else {
            val tool = new JLanguageTool(lang)
            val matches = tool.check(enName)
            val suggested = new StringBuilder
            if (!matches.isEmpty) {
              val i = matches.iterator()
              while (i.hasNext) {
                val m = i.next()
                val msg = msgs.getOrElse(m.getMessage, m.getMessage)
                suggested.append(msg)
                if (msg == "连续空格") {
                  var from = m.getFromPos
                  var to = m.getToPos
                  if (from - 3 >= 0) from -= 3
                  if (to + 3 < enName.length) to += 3
                  suggested.append(enName.substring(from, to).replace(" ", "&bull;"))
                } else {
                  val replacements = m.getSuggestedReplacements
                  if (!replacements.isEmpty) {
                    suggested.append(enName.substring(m.getFromPos, m.getToPos) + "=>" + replacements.get(0))
                  }
                }
              }
              rs.put(journal, s"${suggested}")
            }
          }
    }
    rs.toMap
  }

  private def isFormatCorrect(enName: String): (Boolean, String) = {
    val parts = Strings.split(enName)
    val names = Collections.newBuffer[String]
    var errors = 0
    parts foreach { part =>
      val lp = part.toLowerCase
      if (parts.contains(lp)) {
        if (lp == part) {
          names.addOne(part)
        } else {
          if (lp == "the" && part == "The" && enName.startsWith("The ")) {
            names.addOne(part)
          } else {
            errors += 1
            names.addOne(s"*${part}*")
          }
        }
      } else {
        if (Character.isUpperCase(part.charAt(0)) || symbols.contains(part.charAt(0))) {
          names.addOne(part)
        } else {
          errors += 1
          names.addOne(s"*${part}*")
        }
      }
    }
    if (errors > 0) {
      (false, names.mkString(" "))
    } else {
      (true, null)
    }
  }
}
