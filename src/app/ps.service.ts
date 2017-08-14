import { Injectable } from '@angular/core';
import { Shell } from 'node-powershell';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/observable/fromPromise';
import 'rxjs/add/operator/do';
import 'rxjs/Rx';

@Injectable()
export class PSService {
  public _shell: Shell = new Shell({
    executionPolicy: 'Bypass',
    noProfile: true
  });
  constructor() { }

  run(script, param): Observable<any> {
    let shellOutput;
    this._shell.addCommand(script, param);
    return Observable.fromPromise(this._shell.invoke())
                     .do(data => console.log('server data:', data))
                     .map(data => data)
                     .catch(this.handleError);
  }


    private handleError (error: any) {
    // In a real world app, we might use a remote logging infrastructure
    // We'd also dig deeper into the error to get a better message
    let errMsg = (error.message) ? error.message :
      error.status ? `${error.status} - ${error.statusText}` : 'Command error';
    console.error(errMsg); // log to console instead
    this._shell.dispose();
    return Observable.throw(errMsg);
  }
}
