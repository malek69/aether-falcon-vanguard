#!/usr/bin/env python3
import os, struct

PAL_EON_SUNSET = [
    0x00080C1C, # 240: gleboki granat nocy
    0x00162244, # 241: indygo
    0x002B3A68, # 242: stalowy blekit
    0x00525E8A, # 243: chlodny polcien
    0x008C6A78, # 244: cieply zmierzch
    0x00C87448, # 245: miedziany horyzont
    0x00E89A54, # 246: bursztynowe swiatlo
    0x00FAD07A, # 247: zlote podswietlenie krawedzi (Rim Light)
    0x00101420, # 248: ciemna sylwetka (Cien 1)
    0x001E2638, # 249: pancerz ciemny (Cien 2)
    0x0034425E, # 250: pancerz sredni (Ton 3)
    0x005A7096, # 251: pancerz jasny (Ton 4)
    0x00FF3848, # 252: alarm / czerwony reflektor
    0x0028E8FF, # 253: wizjer HUD / energia Eteru
    0x00FFD430, # 254: zloto / dopalacz
    0x00FFFFFF, # 255: biel blysku
]

def pack_scene(out_path, palette, acts):
    buf = bytearray(b"AFSC")
    buf += struct.pack(">H", len(acts))
    for col in palette:
        buf += struct.pack(">I", col)
    for dur, sky_top, sky_bot, subtitle, polys in acts:
        sub_b = subtitle.encode("ascii", "ignore")
        if len(sub_b) % 2 == 1:
            sub_b += b" "
        buf += struct.pack(">HBBH", dur, sky_tÜÚÞWØ›Ý[ŠÝX—ØŠJBˆYˆ
ÏHÝX—Ø‚ˆYˆ
ÏHÝXÝœXÚÊ’‹[ŠÛ\ÊJBˆ›ÜˆÛÛÚY—ÜÝ\—Ù[™[ˆÛ\Î‚ˆ\ÜÙ\[Š—ÜÝ\
HOH[Š—Ù[™
H[™ÈH[Š—ÜÝ\
HHM‚ˆYˆ
ÏHÝXÝœXÚÊˆ‹ÛÛÚY[Š—ÜÝ\
JBˆ›ÜˆH[ˆ—ÜÝ\‚ˆYˆ
ÏHÝXÝœXÚÊš‹JBˆ›ÜˆH[ˆ—Ù[™‚ˆYˆ
ÏHÝXÝœXÚÊš‹JBˆÜË›XZÙY\œÊÜËœ]™\›˜[YJÝ]Ü]
K^\ÝÛÚÏUYJBˆÚ]Ü[ŠÝ]Ü]ØˆŠH\ÈŽ‚ˆ‹Üš]JYŠBˆš[
ˆ–ÐQ”Ð×H˜YÝØ[›ÈÛÝ]Ü]H
Û[ŠYŠ_H‹Û[ŠXÝÊ_HZÝÝÊHŠB‚™YˆZ[Ú[›×ÜØÙ[™J
N‚ˆXÝHH
ML‹”ÓÓTÈRTTÑHHTÒÈÐÔSP“H‹Âˆ
‹ÊMMJK
NLJK
LÌMJK
ŒN
K
ŽM
K
ÌNKLLŠK
ÌNKMÍJK
MÍJWKˆÊMŒŠK
N
K
LŒ‹M
K
NL‹L
K
ŒLÍŠK
ÌNKLJK
ÌNKN
K
N
WJKˆ
ÊMŽ
K
ÌNKMŽ
K
ÌNKMJK
MJWKˆÊMÍ
K
ÌNKMÍ
K
ÌNKMJK
MJWJKˆ
KÊLÌ‹MŠK
ŒMM
K
ŽNM
K
ŒÍNŠK
MN
WKˆÊLM
K
Œ‹MŠK
Ì‹MŒŠK
ŒŽN
K
LNŠWJKˆ
ËÊLÌ‹MŠK
ŒMM
K
ŽNM
K
ŽKMÊK
ŒLËMLÊWKˆÊLM
K
Œ‹MŠK
Ì‹MŒŠK
ŽL‹MŠK
ŒKM
WJKˆ
ÊÎMJK
‹N
K
Œ‹MMŠK
MMŠK
MN
K
L‹MJWKˆÊL‹MJK
ŒMÍŠK
Í‹M
K
MM
K
LNŠK
LNMJWJKˆ
ËÊÍMMŠK
‹MMÊK
MKN
K
KNL
K
ÍËMŒJWKˆÊM
K
M‹MJK
LKNŠK
LËN
K
LKMM
WJKˆJBˆXÝˆH
MLË–‹LMSU“ÔÈHÐS“ÔHÐÒÑQ‹Âˆ
Ê
K
ÌNK
K
ŽŽ
K
Ž
WKˆÊ
K
ÌNK
K
KŽ
K
MKŽ
WJKˆ
KÊMJK
ÍKNMJK
ŽKNMJK
ÌNKMJWKˆÊMJK
KMÌŠK
ÍKMÌŠK
ÌNKMJWJKˆ
LËÊLMKLLŠK
ŒKLLŠK
ŒL‹MN
K
LMN
WKˆÊMKMŠK
ŒKMŠK
ŒÍKMŠK
KMŠWJKˆ
MÊMLŽ
K
MÌ‹LŽ
K
MŒM
WKˆÊLÎLN
K
N‹LN
K
MŒM
WJKˆJBˆXÝÈH
MLKKQ•T•T“‘T”ÈQÓ’UQH•S•TÕ‹Âˆ
ÊML
K
ÌNKML
K
ÌNKMJK
MJWKˆÊNJK
ÌNKNJK
ÌNKMJK
MJWJKˆ
LÊKM
K
MŒLŒŠK
ŒÍKM
K
NMKMÌŠK
LKMÌŠWKˆÊKMJK
MŒLÌŠK
MKMJK
ŒKNLŠK
LMKNLŠWJKˆ
L‹ÊLÍMŒŠK
ML‹MŒŠK
M‹NLŠK
MNLŠWKˆÊLMÎ
K
ML‹MÎ
K
MKŒÎ
K
LÌKŒÎ
WJKˆ
L‹ÊMŽMŒŠK
N‹MŒŠK
NNLŠK
MÍNLŠWKˆÊMŽMÎ
K
NM‹MÎ
K
NKŒÎ
K
MÍKŒÎ
WJKˆ
MÊLÎM
K
MM
K
MËNŠWKˆÊLÌN
K
MN
K
LÎKŒN
WJKˆ
MÊMÌ‹M
K
N‹M
K
MÍËNŠWKˆÊMÌ‹N
K
NLN
K
NKŒN
WJKˆJBˆXÝH
MLË•S‘ÕPT‘ÒS‘ÈH‘PÕÔˆÈ”“Ó•‹Âˆ
ËÊNMJK
MKMÎ
K
ŒMKN
K
ÌNKMÌ
K
ÌNKMJK
MJWKˆÊŒJK
MKŒLŠK
ŒMKŒN
K
ÌNKŒ
K
ÌNKMJK
MJWJKˆ
LKÊLKMMJK
MŒLJK
ŒMKMMJK
MŒMJWKˆÊLKLJK
MŒŠK
NMKLJK
MŒLM
WJKˆ
ËÊLKMMJK
MŒLJK
ŒMKMMJK
Œ‹MMÊK
MŒLÌJWKˆÊLKLJK
MŒŠK
NMKLJK
NKLÊK
MŒÊWJKˆJBˆXÚ×ÜØÙ[™J™]KÜØÙ[™WÚ[›Ë˜š[ˆ‹SÑSÓ—ÔÕS”ÑUØXÝKXÝ‹XÝËXÝJB‚™YˆZ[ØÜš\Ú\×ÜØÙ[™J
N‚ˆXÝHH
ML‹”‘QST•H‘TÔTH“QU”‘PPÒ‹Âˆ
ÊMÌ
K
ÌNKMÌ
K
ÌNKMJK
MJWKˆÊMÌ
K
ÌNKMÌ
K
ÌNKMJK
MJWJKˆ
L‹ÊLKLŠK
NMKLŠK
ŒMKMŠK
MŒL
K
LKMŠWKˆÊLK
K
ŒMK
K
‹LŠK
MŒMŠK
ÎLŠWJKˆ
ÊLÍK
K
NK
K
NNM
K
MŒLLŠK
LŒ‹M
WKˆÊLŒMŠK
ŒMŠK
ŒNN
K
MŒLŠK
L‹N
WJKˆJBˆXÝˆH
MK’S•TÑTSSQQPUSHHQ‘S‘ÓÓTÈ‹Âˆ
KÊLŒ
K
MKMJK
LÌLŒ
K
MKLÍJWKˆÊMKL
K
KŒŠK
LÍKL
K
KLLŠWJKˆ
KÊNLLMJK
KL
K
ŽLMJK
KLÌ
WKˆÊNKJK
MKMŠK
ÌKJK
MKL
WJKˆ
L‹ÊLLŠK
L‹LLŠK
MKLŒŠWKˆÊÍ‹ŠK
M‹ŠK
‹MŠWJKˆ
L‹ÊŒÎLÊK
L‹LÊK
KLMÊWKˆÊÍŠK
ÍŠK
ML
WJKˆJBˆXÚ×ÜØÙ[™J™]KÜØÙ[™WØÜš\Ú\Ë˜š[ˆ‹SÑSÓ—ÔÕS”ÑUØXÝKXÝ—JB‚™YˆZ[ÝšXÝÜžWÜØÙ[™J
N‚ˆXÝHH
ML‹Ë•T‘ÑU‘UUSV‘QHÓÓSˆÔ’V“Óˆ‹Âˆ
ËÊN
K
LLMŒŠK
ŒŒMÌŠK
ÌNKMMŠK
ÌNKMJK
MJWKˆÊNLŠK
LLMÍŠK
ŒŒN
K
ÌNKMÌ
K
ÌNKMJK
MJWJKˆ
LKÊLŒLN
K
MŒMŠK
ŒLN
K
MŒLÌ
WKˆÊMKLÌŠK
MŒL
K
ŒKLÌŠK
MŒM
WJKˆ
ËÊLŒLN
K
MŒMŠK
ŒLN
K
NLŒ
K
MŒLŠWKˆÊMKLÌŠK
MŒL
K
ŒKLÌŠK
ŒLLÍJK
MŒLLJWJKˆJBˆXÝˆH
MLK‹”ÓÓTÈÓÓ‘‘QTUSÓˆÐSUTÈS‘ÕPT‘‹Âˆ
ÊMÌŠK
ÌNKMÌŠK
ÌNKMJK
MJWKˆÊMÌŠK
ÌNKMÌŠK
ÌNKMJK
MJWJKˆ
KÊLKMJK
LÍMŽ
K
MM‹LÍŠK
MÎLÍŠK
NM‹MÌŠK
Œ‹MJWKˆÊLKMJK
LÍM
K
MM‹LÌŠK
MÎLÌŠK
NM‹MŽ
K
Œ‹MJWJKˆ
ËÊMÌ‹LÍŠK
N‹LÎ
K
NNMÌŠK
NLMÍ
K
MÍKMŠWKˆÊMÌ‹LÌŠK
N‹LÍ
K
NNMŽ
K
NLMÌ
K
MÍKLÎ
WJKˆ
MÊNLŠK
ŒMN
K
ŒŒ‹L
K
NM‹LÍ
WKˆÊNLN
K
ŒN
K
Œ‹M
K
NM‹LŠWJKˆJBˆXÚ×ÜØÙ[™J™]KÜØÙ[™WÝšXÝÜžK˜š[ˆ‹SÑSÓ—ÔÕS”ÑUØXÝKXÝ—JB‚šYˆ×Û˜[YW×ÈOH—×ÛXZ[—×ÈŽ‚ˆZ[Ú[›×ÜØÙ[™J
BˆZ[ØÜš\Ú\×ÜØÙ[™J
BˆZ[ÝšXÝÜžWÜØÙ[™J
B