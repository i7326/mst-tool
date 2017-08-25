import { Injectable, NgZone } from '@angular/core';
import { Shell } from 'node-powershell';
import { Observable } from 'rxjs/Observable';
import { remote } from 'electron';
import { join } from 'path';
import { env } from 'process';
import { open } from 'temp-fs';
import { createWriteStream, createReadStream } from 'fs';
import { LoaderService } from './loader/loader.service';
import 'rxjs/add/observable/fromPromise';
import 'rxjs/Rx';

@Injectable()
export class PSService {
  private scriptDir = remote.app.getAppPath();
  private script:string[];
  public shell: Shell = new Shell({
    executionPolicy: 'Bypass',
    noProfile: true
  });
  constructor(private loaderService: LoaderService, private zone: NgZone) {
    let script:string[];
    open({suffix:'.ps1'},function (err, file) {
    if (err) { throw err; }
      createReadStream(`${join(remote.app.getAppPath(), 'scripts', 'generate-mst.ps1')}`).pipe(createWriteStream(join(file.path)));
      script['generate-mst'] = file;
    });
    console.log(script);

      //var tmpobj = dirSync();
    //console.log(platform());
// Manual cleanup
      //tmpobj.removeCallback();
    createReadStream(`${join(this.scriptDir, 'scripts', 'generate-mst.ps1')}`).pipe(createWriteStream(join(env.TMP,'newLog.log')));
  }

  run(script, param): Observable<any> {
    let shellOutput;
    this.zone.run(() => { this.showLoader() });
    this.shell.addCommand(`&"${join(this.scriptDir, 'scripts', script)}"`, param);
    return Observable.fromPromise( this.shell.invoke())
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
    this.shell.dispose();
    return Observable.throw(errMsg);
  }

  private showLoader(): void {
    this.loaderService.show();
  }

  private hideLoader(): void {
    this.loaderService.hide();
  }

  ngOnDestroy() {
    console.log('destroyed');
  }
}
