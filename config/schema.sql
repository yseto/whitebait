CREATE TABLE `xen_host` (
  `id` INTEGER NOT NULL PRIMARY KEY,
  `hostname` varchar(128) NOT NULL,
  'create_at' INTEGER NOT NULL,
  'update_at' INTEGER NOT NULL
);

CREATE TABLE `xen_vm` (
  `id` INTEGER NOT NULL PRIMARY KEY,
  `hostname` varchar(128) NOT NULL,
  `xen_host_id` INTEGER NOT NULL,
  'create_at' INTEGER NOT NULL,
  'update_at' INTEGER NOT NULL
);

CREATE TABLE `xen_ip` (
  `id` INTEGER NOT NULL PRIMARY KEY,
  `ipaddr` varchar(128) NOT NULL,
  `xen_vm_id` INTEGER NOT NULL,
  'create_at' INTEGER NOT NULL,
  'update_at' INTEGER NOT NULL
);



