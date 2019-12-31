## Version 1.0

This version is not compatible with previous versions. The following are main changes and migration guide:

1. Keyword parameter `strictness` for both `profane?` and `profanity_count` is replaced by `strategies`.

    ```ruby
    # 'strict mode' before
    pf.profane?('text', strictness: :strict)
  
    # 'strict mode' now
    pf.profane?('text', strategies: :all)

    # 'tolerant mode' before
    pf.profane?('text', strictness: :tolerant)
 
    # 'tolerant mode' now
    pf.profane?('text', strategies: :basic)
    ``` 
2. We can compose our own strategies:

    ```ruby
    # the below two are exactly the same:
    pf.profane?('text', strategies: [:leet, :allow_symbol, :duplicate_characters, :partial_match])
    pf.profane?('text', strategies: :all)
    ```
3. Now the default mode has full support for partial match

    ```ruby
    # before it passes our filter, but now it's marked as profane.
    pf.profane?('youasshole')
    ```

That's it. Enjoy!