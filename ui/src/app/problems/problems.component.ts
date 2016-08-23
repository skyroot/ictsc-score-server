import { Component } from '@angular/core';
import { ApiService, MiniList } from "../common";
import { Time } from "../common";

@Component({
  template: require('./problems.template.jade'),
})
export class Problems extends MiniList {
  constructor(private api: ApiService) {super()}

  ngOnInit() {
    this.fetch();
  }

  get(){
    return this.api.problems.get();
  }

  dateFormat(input: any){ return Time.dateFormat(input); }
}