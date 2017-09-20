import { Injectable, NgZone } from '@angular/core';
import { Observable } from 'rxjs/Observable';
import { LoaderService } from '../components/loader/loader.service';
import 'rxjs/add/observable/fromPromise';
import 'rxjs/Rx';

@Injectable()
export class PowershellService {
  public shell = electron.remote.app.PowerShell();

  constructor(private loaderService: LoaderService, private zone: NgZone) { }

  run(script, param): Observable<any> {
    this.zone.run(() => { this.showLoader() });
    if (param) { this.shell.addCommand(`${script}`, param) }
    else { this.shell.addCommand(`${script}`) };
    return Observable.fromPromise(this.shell.invoke())
      .map(data => data)
      .catch(this.handleError)
      .finally(() => {
        this.zone.run(() => { this.hideLoader() });
      })
  }

  private handleError(error: any) {
    // In a real world app, we might use a remote logging infrastructure
    // We'd also dig deeper into the error to get a better message
    return Observable.throw(error.split('At line:')[0]);
  }

  private showLoader(): void {
    this.loaderService.show();
  }

  private hideLoader(): void {
    this.loaderService.hide();
  }

}
