import { Injectable, NgZone } from '@angular/core';
import { Shell } from 'node-powershell';
import { Observable } from 'rxjs/Observable';
import { remote } from 'electron';
import { join } from 'path';
import { LoaderService } from './loader/loader.service';
import 'rxjs/add/observable/fromPromise';
import 'rxjs/add/operator/do';
import 'rxjs/Rx';

@Injectable()
export class PSService {
  private _scriptdir = remote.app.getAppPath();
  public _shell: Shell = new Shell({
    executionPolicy: 'Bypass',
    noProfile: true
  });
  constructor(private loaderService: LoaderService, private zone: NgZone) { }

  run(script, param): Observable<any> {
    let shellOutput;
    this.zone.run(() => { this.showLoader() });
    this._shell.addCommand(`&"${join(this._scriptdir, 'scripts', script)}.ps1"`, param);
    return Observable.fromPromise( this._shell.invoke())
      .do(data => console.log(data))
      .map( data => data )
      .catch(this.handleError)
      .finally(() => {
        this.zone.run(() => { this.hideLoader() });
      })
  }


  private handleError(error: any) {
    // In a real world app, we might use a remote logging infrastructure
    // We'd also dig deeper into the error to get a better message
    let errMsg = (error.message) ? error.message :
      error.status ? `${error.status} - ${error.statusText}` : 'Command error';
    console.error(errMsg); // log to console instead
    this._shell.dispose();
    return Observable.throw(errMsg);
  }

  private showLoader(): void {
    this.loaderService.show();
  }

  private hideLoader(): void {
    this.loaderService.hide();
  }
}
