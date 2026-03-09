const steps = [
  {
    step: "01",
    emoji: "✏️",
    title: "貸し借りを記録",
    description:
      "「＋」ボタンを押して、相手の名前・金額・メモ・返済期日を入力するだけ。30秒で記録完了。",
    hasImage: true,
  },
  {
    step: "02",
    emoji: "🔔",
    title: "期日に通知が届く",
    description:
      "返済期日になると自動でプッシュ通知。うっかり忘れる心配がありません。",
    hasImage: false,
  },
  {
    step: "03",
    emoji: "💬",
    title: "LINEでスマートに催促",
    description:
      "通知からそのままLINEへ。内容と金額を自動でメッセージに組み込み、ワンタッチで送信できます。",
    hasImage: false,
  },
];

export function HowItWorksSection() {
  return (
    <section className="py-20 sm:py-28 bg-gradient-to-br from-blue-600 to-indigo-700 relative overflow-hidden">
      <div
        aria-hidden="true"
        className="absolute top-0 left-1/2 -translate-x-1/2 h-[400px] w-[800px] rounded-full bg-white/5 blur-3xl"
      />

      <div className="relative mx-auto max-w-4xl px-4 sm:px-6">
        <div className="text-center mb-14">
          <p className="text-sm font-semibold uppercase tracking-widest text-blue-200 mb-3">
            使い方
          </p>
          <h2 className="text-3xl font-black tracking-tight text-white sm:text-4xl">
            3ステップで使い始める
          </h2>
          <p className="mt-4 text-blue-100 max-w-xl mx-auto">
            難しい設定は一切なし。今すぐ始められます。
          </p>
        </div>

        <div className="space-y-10">
          {steps.map((step, index) => (
            <div key={step.step}>
              <div className="flex flex-col sm:flex-row items-start sm:items-center gap-6">
                {/* Step indicator */}
                <div className="flex-shrink-0 flex items-center gap-4 sm:gap-0 sm:flex-col sm:items-center w-full sm:w-20">
                  <div className="relative inline-flex h-16 w-16 items-center justify-center rounded-2xl bg-white/10 backdrop-blur-sm border border-white/20 text-3xl">
                    {step.emoji}
                    <span className="absolute -top-2 -right-2 flex h-6 w-6 items-center justify-center rounded-full bg-white text-xs font-black text-primary">
                      {step.step}
                    </span>
                  </div>
                  {/* Connector line on mobile */}
                  {index < steps.length - 1 && (
                    <div aria-hidden="true" className="flex-1 h-0.5 bg-white/20 sm:hidden" />
                  )}
                </div>

                {/* Vertical connector on desktop */}
                <div className="hidden sm:flex flex-col items-center self-stretch">
                  <div className="flex-1" />
                  {index < steps.length - 1 && (
                    <div className="w-0.5 flex-1 bg-white/20" />
                  )}
                </div>

                {/* Content */}
                <div className="flex-1 pb-2">
                  <h3 className="text-xl font-bold text-white mb-1">{step.title}</h3>
                  <p className="text-sm leading-relaxed text-blue-100">
                    {step.description}
                  </p>
                </div>
              </div>

              {/* Image placeholder below first step */}
              {step.hasImage && (
                <div className="mt-6 ml-0 sm:ml-24">
                  <div className="rounded-2xl bg-white/10 border-2 border-dashed border-white/30 p-6 flex flex-col items-center justify-center gap-3 h-[200px] sm:h-[240px] max-w-sm">
                    <svg className="h-10 w-10 text-white/40" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z" />
                    </svg>
                    <p className="text-sm text-white/50 text-center">
                      貸し借り記録画面のスクリーンショット
                    </p>
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
