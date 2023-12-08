belongs_to 参数foreign_key和primary_key含义



~~~
class Account < ApplicationRecord
  belongs_to :supplier, foreign_key: :xx_id, primary_key: :second_id
end

~~~

```
  a = Account.first
  a.supplier
  
```

> 通常 在accounts表中找到 supplier_id(默认根据 belongs_to的参数与_id组合)的值，与suppliers表中id值匹配(默认id主键)，
> 但是设置了foreign_key和primary_key后，变成在accounts表中使用xx_id字段值与suppliers表中的second_id字段匹配

```
class Supplier < ApplicationRecord
  has_one :account, foreign_key: :xx_id, primary_key: :second_id
end
```

> 通常 在suppliers表中找到 id(默认主键)的值，与accounts表中supplier_id值匹配(默认根据 belongs_to的参数与_id组合)，
> 但是设置了foreign_key和primary_key后，变成在suppliers表中使用second_id字段值与accounts表中的xx_id字段匹配
