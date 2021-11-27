'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "asd.zip": "a5e7ac9d054007a53e56d5f94eb88edc",
"assets/AssetManifest.json": "1e4539fa5cf7b7e2225f3faab90c5215",
"assets/assets/fonts/hkgrotesk/HKGrotesk-Bold.ttf": "cc608387c880cd6c99b8ce396969ce26",
"assets/assets/fonts/hkgrotesk/HKGrotesk-BoldItalic.ttf": "62bb92e262ae394e4c8f41bb627c4313",
"assets/assets/fonts/hkgrotesk/HKGrotesk-Italic.ttf": "f960c8317a4876098babaeda76eab8be",
"assets/assets/fonts/hkgrotesk/HKGrotesk-Light.ttf": "a48255409231243f16c3d39187423951",
"assets/assets/fonts/hkgrotesk/HKGrotesk-LightItalic.ttf": "0a58de60e6700518806d23c78409a950",
"assets/assets/fonts/hkgrotesk/HKGrotesk-Medium.ttf": "903a340ca258974c6205ac2d917c62f9",
"assets/assets/fonts/hkgrotesk/HKGrotesk-MediumItalic.ttf": "3a4e92f09b906e44c1b50ff569848c0b",
"assets/assets/fonts/hkgrotesk/HKGrotesk-Regular.ttf": "2a243cd50698dd639c9c3eb6b6449ee7",
"assets/assets/fonts/hkgrotesk/HKGrotesk-SemiBold.ttf": "416192584e88037eb1f1ac924cf83a9c",
"assets/assets/fonts/hkgrotesk/HKGrotesk-SemiBoldItalic.ttf": "062379eb9e89f38e082fad2ddee3ea07",
"assets/assets/vacto_full.png": "313993171518ed94395d3e2c0270db35",
"assets/assets/vacto_logo.png": "1ebd4322925d717c4fe65ed0af454c1c",
"assets/country-flags/ad.png": "f7907af64233b41f84011122eec700ca",
"assets/country-flags/ae.png": "5636a857f0bfa02eddf9a1955c05cb82",
"assets/country-flags/af.png": "a3b1a31277e117b6c51e32188572a075",
"assets/country-flags/ag.png": "63e61635acd9279407064c4611118d6d",
"assets/country-flags/ai.png": "6dfc51d0fe8da1cb27a357bfa2ee6a5a",
"assets/country-flags/al.png": "8c7dd841abd9147557e2b00a7363bec6",
"assets/country-flags/am.png": "2edb6888a02ac48f7dd756aa019d87f8",
"assets/country-flags/ao.png": "dbd4c5c5d37b58246675c9ddf86cd285",
"assets/country-flags/aq.png": "c249f6fa0727d1ac51977e9c051c6a52",
"assets/country-flags/ar.png": "9e0f442ead0a9464b1d3dbee73fff7b6",
"assets/country-flags/as.png": "456a07e0d29b9db6ed76ff73c04b8d59",
"assets/country-flags/at.png": "5277c4a6c21ff5e3e5ab6df39c22c2fd",
"assets/country-flags/au.png": "de40991f1bddc5e26963e36aa7dbe61e",
"assets/country-flags/aw.png": "9c053bbb65fdd2dcfdfa4b397377c9dc",
"assets/country-flags/ax.png": "b7c79b1b2e6160ba545e633114e8b308",
"assets/country-flags/az.png": "a51a041e077a5d7452dd2715566d4b9a",
"assets/country-flags/ba.png": "e6a50039a4c4676ec1702b71ad816a99",
"assets/country-flags/bb.png": "6dd4589d78c298e24a898fbe65c9db40",
"assets/country-flags/bd.png": "fdbca8d341b93c7193b43b2520b59b9d",
"assets/country-flags/be.png": "f983f7bfdca576e9906382505c3630cc",
"assets/country-flags/bf.png": "1c091aa308cfdce7c72a4a4a85178233",
"assets/country-flags/bg.png": "8474f8876c163634c67b4085617db8e1",
"assets/country-flags/bh.png": "f38f9bd902c8b79a1d08d8328f554fdd",
"assets/country-flags/bi.png": "e2b381f13858bee0a412e164e1aafa9d",
"assets/country-flags/bj.png": "cafe2cec32fbf0f2e165897e4ea58310",
"assets/country-flags/bl.png": "a85f1de8b43963c41b74fb884ab58630",
"assets/country-flags/bm.png": "68487d8196a952f36e6d98e3a45716c6",
"assets/country-flags/bn.png": "eab460aee44988d4bf6d81e4990686ec",
"assets/country-flags/bo.png": "33b77410d68f1523a60068146e914794",
"assets/country-flags/bq.png": "99832494a5ca84da1164abe5bcc9b679",
"assets/country-flags/br.png": "6e442c37eadd3b59e4dbca4d24d17fea",
"assets/country-flags/bs.png": "d26b558fb058009b6c992fb834d4afa1",
"assets/country-flags/bt.png": "391ad03b9ce1e3d65daf7c29d6bbd752",
"assets/country-flags/bv.png": "fc42330b3db8f35031dd3bff6c65fb1f",
"assets/country-flags/bw.png": "c7522d1e84b762bc0973c0057315d1d2",
"assets/country-flags/by.png": "b28b4334bba0c356a1a218babb894b1d",
"assets/country-flags/bz.png": "7db2e64e82cef997ac8404bed5fb604c",
"assets/country-flags/ca.png": "fa6d32840c59eca6ecb0273abd2c37e4",
"assets/country-flags/cc.png": "6ebd365a6c084ab427d205734ee33a54",
"assets/country-flags/cd.png": "b884023fd37816b0af1f9b12402b7464",
"assets/country-flags/cf.png": "2b82683a352e21137133330c9a8177e3",
"assets/country-flags/cg.png": "0f042399b6989e4531f6cb4cb5ae2a12",
"assets/country-flags/ch.png": "d5bb551f7ad8696508c39dfc046ecec0",
"assets/country-flags/ci.png": "4234f6c8ab045536b66fbf3ff14a8369",
"assets/country-flags/ck.png": "0728a3b7b3557fe2f6a147f935b661f9",
"assets/country-flags/cl.png": "f22e8e7f6ec61be1eae59d6dcf84b2b0",
"assets/country-flags/cm.png": "7314ffcbd40df68133cd58d8f9a9ae13",
"assets/country-flags/cn.png": "4a232403ea27b339556f5b76b83f406a",
"assets/country-flags/co.png": "024cb74908e0a4f892dff95a88f9f556",
"assets/country-flags/cr.png": "d22613b792b0d602c1cfeb8fd0118f79",
"assets/country-flags/cu.png": "61deefd73ff205c6b70bbcc9945bdba3",
"assets/country-flags/cv.png": "5c938590a9a584015fb0192d9f33a05d",
"assets/country-flags/cw.png": "bfa62efbe142ee9d6657034a804478a9",
"assets/country-flags/cx.png": "5c659d58b20e17356051d42dd8a7f97e",
"assets/country-flags/cy.png": "4c5e63f5f98b9194f92a1975855355d8",
"assets/country-flags/cz.png": "fcefa38504b26e324bcdece01d44f60e",
"assets/country-flags/de.png": "caec7ab537f3437593e2242cd0c5fcd1",
"assets/country-flags/dj.png": "13e865e19af6767e48158b8903462c50",
"assets/country-flags/dk.png": "fe376bc0b1f2931a147ed8d9c922f0f8",
"assets/country-flags/dm.png": "23d6b674958775ec50fc95534e4b7a10",
"assets/country-flags/do.png": "de716f8c5f35713524b0242ebba26ee0",
"assets/country-flags/dz.png": "e2e198c27d9f760b06b0b30727dcb784",
"assets/country-flags/ec.png": "e95f500d2bc8a1bf4907a2d70564e312",
"assets/country-flags/ee.png": "4cbe112373ccfefc9502677518849b67",
"assets/country-flags/eg.png": "21b89eba987bd79001a96eb0182f0f47",
"assets/country-flags/eh.png": "6951a8d9ba3537e5d239ecb9b017d79d",
"assets/country-flags/er.png": "1c76e8a7cee2b2f4139470b6763567a3",
"assets/country-flags/es.png": "faea3527c817f7df27efd835466d0a72",
"assets/country-flags/et.png": "0e67e593aa34600fd4c4aaccd059aaa9",
"assets/country-flags/fi.png": "1798482e2181961e7aebee216aa771c3",
"assets/country-flags/fj.png": "e8d743bf48ad41c8604fbdca1af25d91",
"assets/country-flags/fk.png": "f74bf70163b56f11d6d02cea0f65836e",
"assets/country-flags/fm.png": "bae2b0f7315372ee1e4526d0a3bdb7f8",
"assets/country-flags/fo.png": "70e8b6b05598f1e43917a9551dc6be5c",
"assets/country-flags/fr.png": "e1b6e3c6b48c75d1a5d311a9eeccb7bd",
"assets/country-flags/ga.png": "930ca9ac1f4f42f68ef3337c0b6e3449",
"assets/country-flags/gb-eng.png": "45468168be8b1678243e66a058dd635b",
"assets/country-flags/gb-nir.png": "21a6bb160aaf0e64a7af2a20d3a8d2a2",
"assets/country-flags/gb-sct.png": "8a0816d056b982256ee29f082914530c",
"assets/country-flags/gb-wls.png": "ab9d2fbb905d20d6023b3b0f2cce7788",
"assets/country-flags/gb.png": "85e10772092af12bd3a84ec717b95f32",
"assets/country-flags/gd.png": "92f43029026cd4c5eb95ab5c7dfb6f15",
"assets/country-flags/ge.png": "d327f0c416d76daf8188b0f514324e38",
"assets/country-flags/gf.png": "d72b40af6b07115f4747bf95faad789e",
"assets/country-flags/gg.png": "ca8073f588d106f2b58da8fde8f32019",
"assets/country-flags/gh.png": "3506a87b817d7b305c77e56cee09f11f",
"assets/country-flags/gi.png": "db2d5ede099303ad749714b068c1d82a",
"assets/country-flags/gl.png": "f42992eabeb979f482a9718bc993bb70",
"assets/country-flags/gm.png": "0f5029290169f50e9160177b105888cc",
"assets/country-flags/gn.png": "866fd355aad3c5b2bbfed90d8ac276cf",
"assets/country-flags/gp.png": "e32da13f55fb6f398d63059e7656d2af",
"assets/country-flags/gq.png": "4bca4981e9327e03eccda9decbe13da0",
"assets/country-flags/gr.png": "fc68e94dd4e387e1c43f191a4b32fcb9",
"assets/country-flags/gs.png": "693927db28a0f2b72b18d7a25c26b0bf",
"assets/country-flags/gt.png": "b96af6bb4a335871dd331a38c8a44f3c",
"assets/country-flags/gu.png": "177ad481c3f8b318b663fb2fce7c84b6",
"assets/country-flags/gw.png": "acc3f7c4ead1129e5dd54ef175c3aefa",
"assets/country-flags/gy.png": "02f409e42ecbb72f58508ea3354e0c02",
"assets/country-flags/hk.png": "af5d26cba82ce6fad0067d1e07fbe3ed",
"assets/country-flags/hm.png": "080ac2a60288a5facaa0823bdd54f074",
"assets/country-flags/hn.png": "9945d8cbbd8ce4fa2f7c76adc8771fbf",
"assets/country-flags/hr.png": "ab46a186d3ae37d10914af26e1ee8e2f",
"assets/country-flags/ht.png": "1da22bf10add474064db1d25761447bf",
"assets/country-flags/hu.png": "d64fd8928166e99cd450d98239f46c6e",
"assets/country-flags/id.png": "79eb42890a07a49ccb7470ec43f64c59",
"assets/country-flags/ie.png": "803ac9407ad296da107e23e926259704",
"assets/country-flags/il.png": "d32107e7cc589517ddfbbf5cb94825df",
"assets/country-flags/im.png": "e0aae5a75913f54c7d1db485fcd93259",
"assets/country-flags/in.png": "18f4cd7b58afc0a60f1210e8f6565bde",
"assets/country-flags/io.png": "6e6d5f04def241c1f49a64523dfcc529",
"assets/country-flags/iq.png": "c2085502190c02cbdd0f84763c0fc751",
"assets/country-flags/ir.png": "d4bb7d9320f0399cdb6ac913bb356788",
"assets/country-flags/is.png": "e5d581651a2b106368592ea77ed1d684",
"assets/country-flags/it.png": "2f2caa0d3601def2a7edb0d53d249fd5",
"assets/country-flags/je.png": "5405e748880f38cd902c1de0a24e484b",
"assets/country-flags/jm.png": "41cf780c8e14614f0f34e5341f0221e3",
"assets/country-flags/jo.png": "724fe7a899310766bb4e2620278645ff",
"assets/country-flags/jp.png": "87919291612934d4038c789b1ba9f6f7",
"assets/country-flags/ke.png": "3c66947afc032fea936e46a0ff00684a",
"assets/country-flags/kg.png": "1456dbdbdead61dbe43fe58cf7f56fbb",
"assets/country-flags/kh.png": "450f1d0226f8d829db4c48efc313bf80",
"assets/country-flags/ki.png": "ffd061de42d1270f979b1f9fe201bbe7",
"assets/country-flags/km.png": "67cc65a500f876afaf7b8744bc701558",
"assets/country-flags/kn.png": "18f451d1fbcf71d42e8ad3f40b183f8d",
"assets/country-flags/kp.png": "11b53b355b8cc93429e719854f742403",
"assets/country-flags/kr.png": "5f72d6630b53d7cb9f1dcdda3b7dc150",
"assets/country-flags/kw.png": "c543f5f97d8076062001b1c4e1103538",
"assets/country-flags/ky.png": "7f6748d3de1c2adbbca870734d8afdb5",
"assets/country-flags/kz.png": "76539d79a0adb76cd360868a3134de52",
"assets/country-flags/la.png": "283d3baf4e6e80fd6429adfcabe9e208",
"assets/country-flags/lb.png": "29a02a620bea1ba63a967f4f67d50d9e",
"assets/country-flags/lc.png": "0f6ec1f7c294e71cd062ea6cabda383e",
"assets/country-flags/li.png": "61f82fed072c72f629d350d108073207",
"assets/country-flags/lk.png": "8b93ad8a43f51b9fa963a96e347066df",
"assets/country-flags/lr.png": "d87a1dc0f6d9f540982de4d82ca6ff6c",
"assets/country-flags/ls.png": "5cea13d58455b625700a0035e5a8459b",
"assets/country-flags/lt.png": "c592671139e456b072ebe10e56ca7de0",
"assets/country-flags/lu.png": "7cc1f4ea9adea6e251f53ac7742bdc69",
"assets/country-flags/lv.png": "cf9c4bef79d1bf15f42a8c60f01e1150",
"assets/country-flags/ly.png": "85fee4fc715a3f22e868a052c583de87",
"assets/country-flags/ma.png": "6703ae3629064caed094752aa1dad164",
"assets/country-flags/mc.png": "82dde3d43840cd56588ef3df262cb2e5",
"assets/country-flags/md.png": "7c1daefec04bc766ef2810da9272a276",
"assets/country-flags/me.png": "00d29ae6952d79e2faec18390164263a",
"assets/country-flags/mf.png": "e1b6e3c6b48c75d1a5d311a9eeccb7bd",
"assets/country-flags/mg.png": "b8a7a64eade8ca9faf07b2678048f629",
"assets/country-flags/mh.png": "99b9fd086c90b80e47b8a57575aebdac",
"assets/country-flags/mk.png": "4fc3e0115ad528b293447d8ed3739bce",
"assets/country-flags/ml.png": "0f30009feeea2697bab305ce34d1ba9b",
"assets/country-flags/mm.png": "a0ec4854e23957095dc06e246d20b737",
"assets/country-flags/mn.png": "fbca2f5c9fcbe430e89e664d54ec126e",
"assets/country-flags/mo.png": "83d43665e58415c928c50c8ea2d1a590",
"assets/country-flags/mp.png": "03ccd46724c45bf2363121f121465d13",
"assets/country-flags/mq.png": "dfb07c4e82655173917fbae73b3acc60",
"assets/country-flags/mr.png": "e44d61fafccb9fd109a963abfeb18a4b",
"assets/country-flags/ms.png": "78427a4c702f18b151f6042012ed61a9",
"assets/country-flags/mt.png": "f54ca8379125f1628198befe43a6ef0d",
"assets/country-flags/mu.png": "6f6dd44315f9d74df5cfc5604b464b39",
"assets/country-flags/mv.png": "639bdefdf4875edaeda704959db2c288",
"assets/country-flags/mw.png": "dd83717d6b39c6b82c7f3c6359922eec",
"assets/country-flags/mx.png": "ac2f7e808e7aecc97ccb7ed4c119527a",
"assets/country-flags/my.png": "5fb9cbd326e301ce7b5bf87c42d45eae",
"assets/country-flags/mz.png": "4bacb814ec3c0004e31135e22b5b1072",
"assets/country-flags/na.png": "156afe0bbcb12e88690e4b7cfee3079a",
"assets/country-flags/nc.png": "e240db86abe614f79a0ea87f06f981ad",
"assets/country-flags/ne.png": "2c31f8a2103a054b214bf3385cc520d1",
"assets/country-flags/nf.png": "677a0dbf5342652369aa050ff8fbfadc",
"assets/country-flags/ng.png": "850d950d5a17ca1e33f60395cb5f022a",
"assets/country-flags/ni.png": "111776b9ba3f2b2e90586f0c6c207b68",
"assets/country-flags/nl.png": "d771f40c6e604aec9763cb5822a17d2f",
"assets/country-flags/no.png": "fc42330b3db8f35031dd3bff6c65fb1f",
"assets/country-flags/np.png": "0ec071a610126b447b63d2859b9a6bbb",
"assets/country-flags/nr.png": "619942b0e44b179958164a28547bae5d",
"assets/country-flags/nu.png": "79e3efd848a1fc81bc837f322ca500bc",
"assets/country-flags/nz.png": "4a62f0b36210374e5b43512cd0cd3b5b",
"assets/country-flags/om.png": "63127d00150be7e9bebf828da3865d20",
"assets/country-flags/pa.png": "bcacd480c61fba9f25183cc0a110c6a1",
"assets/country-flags/pe.png": "9e4e599ec2c47312759fb6bf63d37e9f",
"assets/country-flags/pf.png": "214efa5f4491fc93f8c204ebf390ed26",
"assets/country-flags/pg.png": "7bd16900165785140505459c282e5db1",
"assets/country-flags/ph.png": "5807ce70b9684836fd0f86a8cdd74199",
"assets/country-flags/pk.png": "5886f0b36f475c70bef7c19bec3777f3",
"assets/country-flags/pl.png": "20a4843c0041511584ea98cd46f6f5e7",
"assets/country-flags/pm.png": "82238406e9520d3d06bca33b7b90bb2b",
"assets/country-flags/pn.png": "94a1194d36a2d7c535115aa95f2e7bbb",
"assets/country-flags/pr.png": "5e1d4ac5545210d0d8567561d9371014",
"assets/country-flags/ps.png": "b6f76ecb67d89cafdd8f3304eb7f041b",
"assets/country-flags/pt.png": "c0e891c94f04e6d4e774dbdd7f943947",
"assets/country-flags/pw.png": "132997d55cf0247c98e3eac6e6411331",
"assets/country-flags/py.png": "be6b5e96ac25b161cda4c265efa04a30",
"assets/country-flags/qa.png": "31798945467bc4f62151986bf8254e17",
"assets/country-flags/re.png": "dc062272accf11c986350424673d81c4",
"assets/country-flags/ro.png": "ddd404bf187e2802c1e4853e57d3c1de",
"assets/country-flags/rs.png": "47f9673f36f78bbd88e7d010b755d268",
"assets/country-flags/ru.png": "f1f000ce667b1d7e8bfe972406dde974",
"assets/country-flags/rw.png": "d8f49834f06b7e77225055e4cde41121",
"assets/country-flags/sa.png": "7643781f8326152d08586da4932ea60c",
"assets/country-flags/sb.png": "495a83aad02f47520c14825bd175a14d",
"assets/country-flags/sc.png": "5239a09070403522ee95ab628130375b",
"assets/country-flags/sd.png": "b62c9aaeb43e0dcd64421f1448874ab5",
"assets/country-flags/se.png": "42a98e96c67a29d55f058a16b04565f6",
"assets/country-flags/sg.png": "71af7ef7f9f5ef0c5ff8ddd853bbd214",
"assets/country-flags/sh.png": "abbfc7d414349110516ff403d07f3fc9",
"assets/country-flags/si.png": "3a4a98277733367970e7f56b16b86612",
"assets/country-flags/sj.png": "fc42330b3db8f35031dd3bff6c65fb1f",
"assets/country-flags/sk.png": "fe9c9964d4fcf39ef23332f6019e4c80",
"assets/country-flags/sl.png": "5505a4324d464674e115f2780339f866",
"assets/country-flags/sm.png": "7bd7207a4fefe5c03ac76bd99d35c187",
"assets/country-flags/sn.png": "a9bc2818705c43f27d5d9cd2c5ed1bab",
"assets/country-flags/so.png": "557974c6c4d0e2c1e1eeceb6133a2f97",
"assets/country-flags/sr.png": "e83cf49ac63b32bcc9b2a13b049439e5",
"assets/country-flags/ss.png": "4e1145f7b954b322e1ad250bb1669d7b",
"assets/country-flags/st.png": "fd7740a6845c821979bfb6789ee2a86a",
"assets/country-flags/sv.png": "0a0c238cd9b2f771ed54a8c91e2d09a2",
"assets/country-flags/sx.png": "e97ff80133697006640dad4ac4e00979",
"assets/country-flags/sy.png": "96969619e5ea1765a9327dd90ae02e86",
"assets/country-flags/sz.png": "c2bcd443cbfd77a8daafcb6d30d867c4",
"assets/country-flags/tc.png": "fe49416c774dc8ddc9cef056ad443407",
"assets/country-flags/td.png": "b87f7a351dc7c97ff29f5769deb88887",
"assets/country-flags/tf.png": "a0503de14c7c75316df76c01dbee1ecf",
"assets/country-flags/tg.png": "829f86de869bd2fdcb954d8f41869b70",
"assets/country-flags/th.png": "354ed5e37df5a04b2bf823a03975a791",
"assets/country-flags/tj.png": "24e70dc7ff194b9f63db9a7a792099ec",
"assets/country-flags/tk.png": "cf9e88cf051b03a299f6f178d3818757",
"assets/country-flags/tl.png": "2ee62c420f8705d7fa131a69fcd962ab",
"assets/country-flags/tm.png": "2fc2f34a7f3b47bd3db58fd6d30631a7",
"assets/country-flags/tn.png": "92cdc71fdc58f6f15f834a683a41fb4d",
"assets/country-flags/to.png": "7a651015a44c6b6f42ad6bd411caedd2",
"assets/country-flags/tr.png": "6f7201b3cfd195f0ed46f227e511c421",
"assets/country-flags/tt.png": "5c2b21750121dcebd105a66e6d56cace",
"assets/country-flags/tv.png": "a0e9ad1bd947015daeb23d4be04889a3",
"assets/country-flags/tw.png": "cfb49de051d630fb302c85b045b00168",
"assets/country-flags/tz.png": "e89afa8596099a39ad76ae6216f34772",
"assets/country-flags/ua.png": "c0d58c98a8833f13bafb30b027704f2e",
"assets/country-flags/ug.png": "34f591b6a53152c32d1c98028aefe67e",
"assets/country-flags/um.png": "d9b6929e4b54930a62f1ab1a6d7082f1",
"assets/country-flags/us.png": "d9b6929e4b54930a62f1ab1a6d7082f1",
"assets/country-flags/uy.png": "006c23ba2e7ac178eaa14a0bdb34fa9f",
"assets/country-flags/uz.png": "f48e8e836700cf0be195a0cb7772b8af",
"assets/country-flags/va.png": "7afd134a472259df1fa2e698200e5a0b",
"assets/country-flags/vc.png": "b939e915be08c0090d2ca01d643115ae",
"assets/country-flags/ve.png": "d1125dd8fef587031c261c04b88caa9b",
"assets/country-flags/vg.png": "11663ce2d4934f7c1192c53c3ba07a2f",
"assets/country-flags/vi.png": "eead17540d87accde471bc08df63ba18",
"assets/country-flags/vn.png": "8c4b12d434660b340d6ca7305354e898",
"assets/country-flags/vu.png": "9a156fc20c106e5d758574305d1b801a",
"assets/country-flags/wf.png": "fa99c31c5ae7c08e57225887e6e617e0",
"assets/country-flags/ws.png": "7d9f06d6533b0f4f64c475479d66e92e",
"assets/country-flags/xk.png": "cae7936bdd51beb88e1779100de3bb8d",
"assets/country-flags/ye.png": "43fc0c97a2cda20c259a6c8c81b6e072",
"assets/country-flags/yt.png": "0f4cf3025ad72bf3c7f9076774f09c64",
"assets/country-flags/za.png": "0831ad29160f73eff376e27ffd2a2f30",
"assets/country-flags/zm.png": "85dc0ceb4cd666ff6e00f21fbb7e4083",
"assets/country-flags/zw.png": "66ff8d9088196202e09d1b91b7d5a865",
"assets/difficulty/easy.svg": "ad9fbea0dfe33d48481d7cae857f7f44",
"assets/difficulty/easy_white.png": "875b0723e4c2244a322e0bafa4fbe642",
"assets/difficulty/hard.svg": "34496fc0e93a62f90bf631d790678d33",
"assets/difficulty/hard_white.png": "69571b78a9b649e916594bab64f52b4c",
"assets/difficulty/normal.svg": "47c8312b06ed1f67b36c2346c0d6896c",
"assets/difficulty/normal_white.png": "18c5b02b8b24245ec862aa6c47df0665",
"assets/FontManifest.json": "14d28d59f02161dbfaf437a8715818d5",
"assets/fonts/hkgrotesk/HKGrotesk-Bold.ttf": "cc608387c880cd6c99b8ce396969ce26",
"assets/fonts/hkgrotesk/HKGrotesk-BoldItalic.ttf": "62bb92e262ae394e4c8f41bb627c4313",
"assets/fonts/hkgrotesk/HKGrotesk-BoldLegacy.ttf": "f01740118ce5cda0e45116d9d1532187",
"assets/fonts/hkgrotesk/HKGrotesk-BoldLegacyItalic.ttf": "5ef3c6a923d4fedf5ef89054dfd226ed",
"assets/fonts/hkgrotesk/HKGrotesk-Italic.ttf": "f960c8317a4876098babaeda76eab8be",
"assets/fonts/hkgrotesk/HKGrotesk-LegacyItalic.ttf": "7df930b0b6a3f04730043144d072c522",
"assets/fonts/hkgrotesk/HKGrotesk-Light.ttf": "a48255409231243f16c3d39187423951",
"assets/fonts/hkgrotesk/HKGrotesk-LightItalic.ttf": "0a58de60e6700518806d23c78409a950",
"assets/fonts/hkgrotesk/HKGrotesk-LightLegacy.ttf": "d8578f66bbf7db2614262b1b38936a2d",
"assets/fonts/hkgrotesk/HKGrotesk-LightLegacyItalic.ttf": "ce09a9ef7e55c4af86892c993afc2530",
"assets/fonts/hkgrotesk/HKGrotesk-Medium.ttf": "903a340ca258974c6205ac2d917c62f9",
"assets/fonts/hkgrotesk/HKGrotesk-MediumItalic.ttf": "3a4e92f09b906e44c1b50ff569848c0b",
"assets/fonts/hkgrotesk/HKGrotesk-MediumLegacy.ttf": "00f366f19f82b1ac3933f758e6ab1c6a",
"assets/fonts/hkgrotesk/HKGrotesk-MediumLegacyItalic.ttf": "ddd894792cce9f6315c9219c32f70df6",
"assets/fonts/hkgrotesk/HKGrotesk-Regular.ttf": "2a243cd50698dd639c9c3eb6b6449ee7",
"assets/fonts/hkgrotesk/HKGrotesk-RegularLegacy.ttf": "1fb3ed5ffd480ace52ae49383d81814e",
"assets/fonts/hkgrotesk/HKGrotesk-SemiBold.ttf": "416192584e88037eb1f1ac924cf83a9c",
"assets/fonts/hkgrotesk/HKGrotesk-SemiBoldItalic.ttf": "062379eb9e89f38e082fad2ddee3ea07",
"assets/fonts/hkgrotesk/HKGrotesk-SemiBoldLegacy.ttf": "6f4d115618f3eb6ee9e9c38df8dc6bf1",
"assets/fonts/hkgrotesk/HKGrotesk-SemiBoldLegacyItalic.ttf": "9b10f5b4cef612d8b6f91faead5139e9",
"assets/fonts/MaterialIcons-Regular.otf": "4e6447691c9509f7acdbf8a931a85ca1",
"assets/login_page/bg-decor-bot-right.png": "cab2ed2c514314df65d8cc525736a1d2",
"assets/login_page/bg-decor-top-left.png": "258f35bf7714ed67ebb8a42981b6678e",
"assets/menu_icon/add.png": "7ca4e807707711fb5e51e13611b2b657",
"assets/menu_icon/challenge.png": "a14508257ca17757b269694ce64748c6",
"assets/menu_icon/gamemode-normal.png": "ba23c01d8ac624f803cfd0b321a7ccbd",
"assets/menu_icon/gamemode-timed.png": "c281362b54e5e5313f71032c1868c602",
"assets/menu_icon/leaderboard.png": "0a082fe2c0977d59623ea3bea2e0c9e1",
"assets/menu_icon/play.png": "bb8cd38c7e2d043434277d54e9ed5279",
"assets/menu_icon/profile.png": "c3fc958e1fe3904570225b70dc302dbb",
"assets/menu_icon/settings.png": "a9fd17c749f65a8d8f894c41c69ba2a9",
"assets/menu_icon/verify.png": "b07d7bdd94f6e01d579858ba763712f6",
"assets/menu_icon/view-data.png": "91f71707f21c8b7950c9839a13ecea82",
"assets/NOTICES": "db744cc0bdcb2ef4d7f85a517e4a272b",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/fluttertoast/assets/toastify.js": "e7006a0a033d834ef9414d48db3be6fc",
"assets/placeholders/testpp.jpg": "755d06458a78f5ee42d1e1803fdfa45c",
"assets/placeholders/wide-pic.png": "9b0a9ceb0097142ed2a3df376502733a",
"assets/play_decor/left-bg.png": "3bfbe8822f865423a871ba6c48b49023",
"assets/play_decor/right-bg.png": "31701b2692d8e8dd10c4a2d5d249bf2b",
"assets/register_page/plus-1.png": "2c0a3ab2928bc7f8327b6af01cca5126",
"assets/register_page/plus-2.png": "9d7bd82be9ba3c3b0f703b04d41cbc7f",
"assets/tiers/tier1.png": "107d93b451c8e18ccd4a0b430c46ee57",
"assets/tiers/tier2.png": "d02e3d12a647814c1c4a0d3ee31ec869",
"assets/tiers/tier3.png": "00924ef3c748c70cddc2cdb94f325582",
"assets/tiers/tier4.png": "d1c0a24e2cb446a4ceaaa9a232e7126e",
"assets/tiers/tier5.png": "30f2a3de6e41f70b1f5067b6d805ec28",
"assets/tiers/tier6.png": "36d9ed1ad2576231014083c6c31e7a7f",
"assets/tiers/tier7.png": "6f4bc7abd17a5be25acf8400d859e824",
"assets/vacto_full.png": "313993171518ed94395d3e2c0270db35",
"assets/vacto_logo.png": "1ebd4322925d717c4fe65ed0af454c1c",
"favicon.png": "a21d2c9d08f58b2128acf90c20aa6cce",
"icons/Icon-192.png": "aee946656b05591f8b1c53f8e934b0d6",
"icons/Icon-512.png": "dc45281da9711b29c0223c06ef1dc0c1",
"index.html": "98f1d66e4f66b8cccdbda0468d5423e2",
"/": "98f1d66e4f66b8cccdbda0468d5423e2",
"main.dart.js": "68722bc32e0c9dbe3a84eec58b7e3f8e",
"manifest.json": "5513c26ac5eec7a6e40262e5326ed52c",
"version.json": "5b8776be5883c32d787d26ceb28c6077"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
