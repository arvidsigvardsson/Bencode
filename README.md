### iOS framework for bencode used in the Bittorrent protocol

Early version does basic encoding and decoding of bencode, via the parse and serialize functions, and includes rudimentary error handling via optional return types.

#### TODO
* Bencode dictionary is currently represented as Swift Dictionary<String:Any> but should probably be Array<(String, Any), to maintain ordering of dictionary entries
* Create tests