import { Model } from '@vuex-orm/core'

export default class Category extends Model {
  static entity = 'categories'

  static fields() {
    return {
      id: this.string(),
      code: this.string().nullable(),
      description: this.string(),
      order: this.number()
      // problems: this.hasMany(Probelm, 'category_id')
    }
  }
}
