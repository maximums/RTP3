-type msg_type() :: subscribe | unsubscribe | data | connect_publisher.
-type is_presistent() :: true | false.
-type header() :: {msg_type(), is_presistent()}.
-record(msg, {header :: header(), body :: any()}).