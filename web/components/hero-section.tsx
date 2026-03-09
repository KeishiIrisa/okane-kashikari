import Image from "next/image";

export function HeroSection() {
  return (
    <section className="relative overflow-hidden bg-gradient-to-br from-blue-50 via-white to-indigo-50 pt-16 pb-24 sm:pt-24 sm:pb-32">
      <div
        aria-hidden="true"
        className="absolute -top-40 -right-40 h-[600px] w-[600px] rounded-full bg-blue-100/50 blur-3xl"
      />
      <div
        aria-hidden="true"
        className="absolute -bottom-40 -left-40 h-[500px] w-[500px] rounded-full bg-indigo-100/50 blur-3xl"
      />

      <div className="relative mx-auto max-w-6xl px-4 sm:px-6">
        <div className="flex flex-col items-center gap-12 lg:flex-row lg:items-center lg:gap-16">
          {/* Text content */}
          <div className="flex-1 text-center lg:text-left">
            <h1 className="text-4xl font-black leading-tight tracking-tight text-gray-900 sm:text-5xl lg:text-6xl">
              友達とのお金の
              <br />
              <span className="text-primary">貸し借り</span>を
              <br />
              スマートに管理
            </h1>

            <p className="mt-6 text-lg leading-relaxed text-gray-600 max-w-lg mx-auto lg:mx-0">
              誰に、いくら貸したか借りたかを<strong>ひと目で確認</strong>。
              期日が近づいたら通知が届き、そのまま
              <span className="text-green-600 font-semibold">LINE</span>
              でスマートに催促できます。
            </p>

            <div className="mt-10 flex flex-col sm:flex-row items-center gap-4 justify-center lg:justify-start">
              <a
                href="https://play.google.com/store"
                target="_blank"
                rel="noopener noreferrer"
                className="transition-transform hover:scale-105 active:scale-95"
              >
                <Image
                  src="https://play.google.com/intl/ja/badges/static/images/badges/ja_badge_web_generic.png"
                  alt="Google Play で手に入れよう"
                  width={200}
                  height={59}
                  className="h-[59px] w-auto"
                  unoptimized
                />
              </a>
            </div>
          </div>

          {/* App mockup */}
          <div className="flex-shrink-0 flex justify-center lg:justify-end">
            <div className="relative">
              <div className="relative mx-auto w-[260px] sm:w-[300px]">
                <div className="rounded-[3rem] bg-white shadow-2xl ring-1 ring-gray-200 overflow-hidden">
                  {/* Status bar */}
                  <div className="flex items-center justify-between px-6 pt-4 pb-2 bg-white">
                    <span className="text-xs font-semibold text-gray-800">22:36</span>
                    <div className="flex items-center gap-1">
                      <div className="flex gap-0.5">
                        {[3, 4, 5, 6].map((h) => (
                          <div
                            key={h}
                            className="w-[3px] rounded-sm bg-gray-800"
                            style={{ height: `${h}px` }}
                          />
                        ))}
                      </div>
                      <svg className="h-3.5 w-3.5 text-gray-800" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M1.5 8.5a13 13 0 0121 0M5 12a9.5 9.5 0 0114 0M8.5 15.5a6 6 0 017 0M12 19h.01" stroke="currentColor" strokeWidth="2" strokeLinecap="round" fill="none" />
                      </svg>
                      <div className="flex items-center gap-0.5">
                        <div className="h-3.5 w-6 rounded-sm border border-gray-800 p-0.5">
                          <div className="h-full w-2/3 rounded-xs bg-gray-800" />
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* App header */}
                  <div className="flex items-center justify-between px-5 pb-3 bg-white">
                    <div className="flex items-center gap-2">
                      <Image src="/app_icon.png" alt="icon" width={24} height={24} className="rounded-md" />
                      <span className="font-bold text-gray-900">お金の貸し借り</span>
                    </div>
                    <div className="flex gap-3 text-gray-400">
                      <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
                      <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" /><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /></svg>
                    </div>
                  </div>

                  {/* Summary cards */}
                  <div className="px-4 pb-3 bg-gray-50 grid grid-cols-2 gap-3">
                    <div className="rounded-2xl bg-white p-4 shadow-sm">
                      <div className="flex items-center gap-1.5 text-xs text-gray-500 mb-2">
                        <div className="h-5 w-5 rounded-full bg-blue-100 flex items-center justify-center">
                          <svg className="h-3 w-3 text-blue-500" fill="currentColor" viewBox="0 0 24 24"><path d="M7 17L17 7M17 7H7M17 7v10" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" fill="none"/></svg>
                        </div>
                        貸している
                      </div>
                      <p className="text-xl font-black text-primary">¥2,100</p>
                    </div>
                    <div className="rounded-2xl bg-white p-4 shadow-sm">
                      <div className="flex items-center gap-1.5 text-xs text-gray-500 mb-2">
                        <div className="h-5 w-5 rounded-full bg-red-100 flex items-center justify-center">
                          <svg className="h-3 w-3 text-red-500" fill="currentColor" viewBox="0 0 24 24"><path d="M17 7L7 17M7 17H17M7 17V7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" fill="none"/></svg>
                        </div>
                        借りている
                      </div>
                      <p className="text-xl font-black text-red-500">¥50,000</p>
                    </div>
                  </div>

                  {/* Tab */}
                  <div className="mx-4 mt-3 mb-3 flex rounded-full bg-gray-100 p-1">
                    <button className="flex-1 rounded-full bg-primary py-1.5 text-xs font-bold text-white shadow-sm">貸しリスト</button>
                    <button className="flex-1 rounded-full py-1.5 text-xs font-medium text-gray-500">借りリスト</button>
                  </div>

                  {/* List items */}
                  <div className="px-4 pb-4 space-y-2">
                    {[
                      { name: "高山", note: "いつかの飲み代・3月10日", amount: "¥1,900" },
                      { name: "高山", note: "3月10日", amount: "¥100" },
                      { name: "高山", note: "期日なし", amount: "¥100" },
                    ].map((item, i) => (
                      <div key={i} className="flex items-center gap-3 rounded-2xl bg-white px-4 py-3 shadow-sm">
                        <div className="h-9 w-9 flex-shrink-0 rounded-full bg-blue-100 flex items-center justify-center">
                          <svg className="h-4 w-4 text-blue-500" fill="none" viewBox="0 0 24 24"><path d="M7 17L17 7M17 7H7M17 7v10" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/></svg>
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="text-xs font-bold text-gray-900">{item.name}</p>
                          <p className="text-[10px] text-gray-400 truncate">{item.note}</p>
                        </div>
                        <p className="text-sm font-bold text-primary flex-shrink-0">{item.amount}</p>
                      </div>
                    ))}
                  </div>

                  {/* FAB */}
                  <div className="flex justify-end px-5 pb-6">
                    <div className="h-12 w-12 rounded-full bg-primary shadow-lg flex items-center justify-center">
                      <svg className="h-6 w-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M12 4v16m8-8H4" /></svg>
                    </div>
                  </div>
                </div>

                <div className="absolute inset-0 rounded-[3rem] bg-primary/10 blur-2xl -z-10 scale-95" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
