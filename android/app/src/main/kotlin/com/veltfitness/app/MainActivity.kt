package com.veltfitness.app

import io.flutter.embedding.android.FlutterFragmentActivity

// FragmentActivity variant is required by plugins that use the Activity
// Result API (RevenueCat, Supabase OAuth flow). Plain FlutterActivity
// triggers ClassCastException at plugin registration time.
class MainActivity : FlutterFragmentActivity()
