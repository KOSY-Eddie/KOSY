This is an early development version of KOSY so there is probably a ton of bugs. To test it out, copy the files to wherever and modify line 3 in `dev_boot.ks` to point to your KOSY installation:

```kerboscript
cd("/your/path/to/KOSY/").
```

Run `dev_boot.ks` to start the base system. All apps in the apps and sys directory should load if registered with `appRegistry:register("Appname", RootAppObject@).`

The Apps directory is intended for user applciations and sys for system applications. The systemtest.ks file in sys and cargo.ks are the best examples to study for now.