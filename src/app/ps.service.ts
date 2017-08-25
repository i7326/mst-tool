import { Injectable, NgZone } from '@angular/core';
import { Shell } from 'node-powershell';
import { Observable } from 'rxjs/Observable';
import { remote } from 'electron';
import { join } from 'path';
import { env } from 'process';
import { createWriteStream, createReadStream } from 'fs';
import { LoaderService } from './loader/loader.service';
import 'rxjs/add/observable/fromPromise';
import 'rxjs/Rx';

@Injectable()
export class PSService {
  private scriptDir = remote.app.getAppPath();
  private TempPath: string = electron.remote.app.TempPath();
  private Scripts: any = { 'get-msiproperty': `${join(this.TempPath, 'get-msiproperty.ps1')}`, 'generate-mst': `${join(this.TempPath, 'generate-mst.ps1')}`};
  public shell: Shell = new Shell({
    executionPolicy: 'Bypass',
    noProfile: true
  });

  constructor(private loaderService: LoaderService, private zone: NgZone) { }

  randomString(m?) {
    var m = m || 9;
    var s = '';
    var r = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    for (var i = 0; i < m; i++) { s += r.charAt(Math.floor(Math.random() * r.length)); }
    return s;
  };
  run(script, param): Observable<any> {
    this.zone.run(() => { this.showLoader() });
    this.shell.addCommand(`&"${this.Scripts[script]}"`, param);
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
    let errMsg = (error.message) ? error.message :
      error.status ? `${error.status} - ${error.statusText}` : 'Command error';
    console.error(errMsg); // log to console instead
    this.shell.dispose();
    return Observable.throw(errMsg);
  }

  private showLoader(): void {
    this.loaderService.show();
  }

  private hideLoader(): void {
    this.loaderService.hide();
  }

}
