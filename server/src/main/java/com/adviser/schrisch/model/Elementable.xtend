package com.adviser.schrisch.model

import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target

interface Elementable {

  def Iterable<Pair<String, ?>> getElements()

}

@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
annotation Editable {
}
