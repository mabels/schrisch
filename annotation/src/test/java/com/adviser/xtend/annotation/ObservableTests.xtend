package com.adviser.xtend.annotation

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test

class ObservableTests {

  extension XtendCompilerTester compilerTester = 
      XtendCompilerTester::newXtendCompilerTester(typeof(Observable)) 
    
 
  @Test def void testObservable() {
    '''
      import com.adviser.xtend.annotations.Observable

      
      @Observable 
      class Person {
        String name
      }
    '''.assertCompilesTo('''
      import java.beans.PropertyChangeSupport;
      import com.adviser.xtend.annotation.Observable;

      @Observable
      @SupressWarnings("all")
      public class Person {
        private String name;
        
        public String getName() {
          return this.name;
        }
        
        public void setName(final String name) {
          String _oldValue = this.name;
          this.name = name;
          _propertyChangeSupport.firePropertyChange(
            "name", _oldValue, name);
        }
        
        private PropertyChangeSupport _propertyChangeSupport 
            = new PropertyChangeSupport(this);
        
        // method addPropertyChangeListener
        // method removePropertyChangeListener
      }
    ''')
  }
}
