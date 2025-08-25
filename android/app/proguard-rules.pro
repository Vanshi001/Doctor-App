-keep class **.zego.** { *; }
-keep class **.**.zego_zpns.** { *; }


# Keep ZegoCloud SDK classes
-keep class im.zego.** { *; }
-keep class com.itgsa.** { *; }
-dontwarn im.zego.**
-dontwarn com.itgsa.**

# Keep MediaUnit classes specifically
-keep class com.itgsa.opensdk.mediaunit.** { *; }
-keep class com.itgsa.opensdk.media.** { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep serialization classes
#-keepclassmembers class * implements java.io.Serializable {
#    static final long serialVersionUID;
#    private static final java.io.ObjectStreamField[] serialPersistentFields;
#    private void writeObject(java.io.ObjectOutputStream);
#    private void readObject(java.io.ObjectInputStream);
#    java.lang.Object writeReplace();
#    java.lang.Object readResolve();
#}