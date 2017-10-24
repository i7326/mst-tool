import { NgModule, ModuleWithProviders } from '@angular/core';
import { CommonModule } from '@angular/common';
import { LoaderComponent } from './components/loader/loader.component';
import { LoaderService } from './components/loader/loader.service';
import { TreeComponent } from './components/tree/tree.component';
import { PowershellService } from './service/powershell.service';
import { MatProgressBarModule } from '@angular/material';
import { TreeModule } from 'angular-tree-component';


/**
 * Do not specify providers for modules that might be imported by a lazy loaded module.
 */

@NgModule({
  imports: [CommonModule, MatProgressBarModule, TreeModule],
  declarations: [LoaderComponent, TreeComponent],
  exports: [LoaderComponent, TreeComponent]
})
export class SharedModule {
  static forRoot(): ModuleWithProviders {
    return {
      ngModule: SharedModule,
      providers: [LoaderService,PowershellService]
    };
  }
}
