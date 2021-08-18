# kdb-gateway
The gateway is a single point of entry to a distributed kdb+ system. It provides service discovery, resiliency and load-balancing for the user, and peace of mind for the system administrator as queries against the database are evaluated in read-only mode.

This implementation includes map-reduce functionality so that aggregations may span real-time and historical database components. Conceptually, this is an extension of the partitioned database: the real-time data becoming just another partition.

To do
  * Use [kdb-arg](https://github.com/dflynch/kdb-arg) to default command line arguments
  * Use [kdb-conn](https://github.com/dflynch/kdb-conn) to manage connections
  * Load default values for .z and _compose_ new functions with desired hook functionality instead of overwriting 
  * Add load-balancing functionality
    * \l lb.q
    * tab
    * add / add service
    * h / send to historical service
    * r / send to real-time service
  * Support exploratory data analysis
    * tables[]
    * meta
  * **WRITE/AUTOMATE TESTS**
