
# Docker copy parameter setting skills

The parameter `src` has two types, `one-item` or `multi-item`

- one-item: one file one dir
- multi-item: all item under dir, src value use endwith '/'

one-item
```sh
docker cp /tmp/file /tmp/file.copy
docker cp /tmp/dir /tmp/dir.copy
```

multi-item
```sh
docker cp /tmp/content/. /tmp/content.copy
```


The parameter `dest` has two types `full-path` or `parent-path` if src use `one-item` type 

- full-path contains the file name, can be renamed.
- parent-path not included file name, the final name will be the same as the source.

full-path
```sh
docker cp /tmp/file /tmp/file.copy
docker cp /tmp/dir /tmp/dir.copy
```

parent-path
```sh
docker cp /tmp/file /tmp/file.parent/
docker cp /tmp/dir /tmp/dir.parent/
```


The parameter `dest` type `full-path` and `parent-path` behave the same if src use `multi-item` type

parent-path
```sh
docker cp /tmp/content/. /tmp/content.copy"
docker cp /tmp/content/. /tmp/content.parent/"
```

|src type | src | dest type | dest | dest exist | result |
|:----- |:----- |:----- |:----- |:----- |:----- |
| one-item   | /tmp/file      | full-path   | /tmp/file.copy       | no   | /tmp/file.copy                 |
|            |                |             | /tmp/file.exist      | file | /tmp/file.exist                |
|            |                |             | /tmp/dir.exist       | dir  | /tmp/dir.exist/file            |
|            |                | parent-path | /tmp/file.parent/    | no   | error ‘not dir’                |
|            |                |             | /tmp/dir.exist/      | dir  | /tmp/dir.exist/file            |
|            |                |             | /tmp/file.exist/     | file | error ‘not dir’                |
|            | /tmp/dir       | full-path   | /tmp/dir.copy        | no   | /tmp/dir.copy                  |
|            |                |             | /tmp/dir.exist       | dir  | /tmp/dir.exist/dir             |
|            |                |             | /tmp/file.exist      | file | error cannot copy’             |
|            |                | parent-path | /tmp/dir.parent/     | no   | /tmp/dir.parent                |
|            |                |             | /tmp/dir.exist/      | dir  | /tmp/dir.exist/dir             |
|            |                |             | /tmp/file.exist/     | file | error ‘cannot overwrite’       |
| multi-item | /tmp/content/. | full-path   | /tmp/content.copy    | no   | /tmp/content.copy/*            |
|            |                |             | /tmp/dir.exist       | dir  | /tmp/dir.exist/*               |
|            |                |             | /tmp/file.exist      | file | error ‘cannot copy’            |
|            |                | parent-path | /tmp/content.parent/ | no   | /tmp/content.parent/*          |
|            |                |             | /tmp/dir.exist/      | dir  | /tmp/dir.exist/*               |
|            |                |             | /tmp/file.exist/     | file | error ‘cannot overwrite’       |