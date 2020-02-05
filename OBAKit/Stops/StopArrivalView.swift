//
//  StopArrivalView.swift
//  OBAKit
//
//  Created by Aaron Brethorst on 1/6/19.
//  Copyright © 2019 OneBusAway. All rights reserved.
//

import UIKit
import AloeStackView
import OBAKitCore

public protocol StopArrivalDelegate: NSObjectProtocol {
    func actionsButtonTapped(arrivalDeparture: ArrivalDeparture)
    func stopArrivalTapped(arrivalDeparture: ArrivalDeparture)
}

/// This view displays the route, headsign, and predicted arrival/departure time for an `ArrivalDeparture`.
///
/// This view is what displays the core information at the heart of the `StopViewController`, and everywhere
/// else that we show information from an `ArrivalDeparture`.
public class StopArrivalView: UIView, Highlightable, Tappable {

    public weak var delegate: StopArrivalDelegate?

    let kUseDebugColors = false

    /// First line in the view; contains route and headsign information.
    ///
    /// For example, this might contain the text `10 - Downtown Seattle`.
    public let routeHeadsignLabel: UILabel = {
        let label = buildLabel()
        label.numberOfLines = 0
        return label
    }()

    /// Second line in the view; contains the arrival/departure time and status relative to schedule.
    ///
    /// For example, this might contain the text `11:20 AM - arriving on time`.
    let timeExplanationLabel = buildLabel()

    // MARK: - Loading

    lazy var loadingIndicator = LoadingIndicatorView()

    public func showLoadingIndicator() {
        guard loadingIndicator.superview == nil else { return }

        leftStack.insertArrangedSubview(loadingIndicator, at: 2)
        loadingIndicator.startAnimating()
    }

    public func hideLoadingIndicator() {
        guard loadingIndicator.superview != nil else { return }

        loadingIndicator.stopAnimating()
        loadingIndicator.removeFromSuperview()
    }

    // MARK: - Minutes to Departure Labels

    /// Appears on the trailing side of the view; contains the number of minutes until arrival/departure.
    ///
    /// For example, this might contain the text `10m`.
    let topMinutesLabel = buildMinutesLabel()

    private lazy var topMinutesWrapper = buildMinutesLabelWrapper(label: topMinutesLabel)

    let centerMinutesLabel = buildMinutesLabel()

    private lazy var centerMinutesWrapper = buildMinutesLabelWrapper(label: centerMinutesLabel)

    let bottomMinutesLabel = buildMinutesLabel()

    private lazy var bottomMinutesWrapper = buildMinutesLabelWrapper(label: bottomMinutesLabel)

    private lazy var minutesStack = UIStackView.verticalStack(arangedSubviews: [])

    private lazy var minutesWrappers: UIView = {
        let wrapper = minutesStack.embedInWrapperView(setConstraints: false)
        NSLayoutConstraint.activate([
            minutesStack.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            minutesStack.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            minutesStack.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor),
            wrapper.heightAnchor.constraint(greaterThanOrEqualTo: minutesStack.heightAnchor)
        ])

        return wrapper
    }()

    private lazy var minutesSpacer = UIView.autolayoutNew()

    // MARK: - Disclosure Indicator

    var showDisclosureIndicator: Bool = false {
        didSet {
            guard oldValue != showDisclosureIndicator else { return }

            if showDisclosureIndicator {
                outerStackView.addArrangedSubview(disclosureIndicator)
            }
            else {
                disclosureIndicator.removeFromSuperview()
            }
        }
    }

    let disclosureIndicator: UIImageView = {
        let view = UIImageView(image: Icons.chevron)
        view.contentMode = .center
        view.setContentHuggingPriority(.required, for: .horizontal)

        return view
    }()

    // MARK: - 'Actions' Button

    var showActionsButton: Bool = false {
        didSet {
            guard oldValue != showActionsButton else { return }

            if showActionsButton {
                outerStackView.addArrangedSubview(actionsButton)
            }
            else {
                actionsButton.removeFromSuperview()
            }
        }
    }

    private lazy var actionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Icons.showMore, for: .normal)
        button.addTarget(self, action: #selector(actionsButtonTapped), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 40.0)
        ])
        return button
    }()

    @objc private func actionsButtonTapped() {
        delegate?.actionsButtonTapped(arrivalDeparture: arrivalDeparture)
    }

    // MARK: - Public Properties

    /// When `true`, decrease the `alpha` value of this cell if it happened in the past.
    public var deemphasizePastEvents = true

    public var formatters: Formatters!

    // MARK: - Data Setters

    public func prepareForReuse() {
        title = nil
        routeHeadsignLabel.text = nil
        timeExplanationLabel.text = nil
        topMinutesLabel.text = ""
        centerMinutesLabel.text = ""
        bottomMinutesLabel.text = ""
    }

    /// If set, this is displayed in the top label in the view.
    /// If it is not set, then the `routeAndHeadsign` property of the `ArrivalDeparture` is displayed.
    public var title: String?

    /// Set this to display data in this view.
    /// - Note: You can also display up to three `ArrivalDeparture`s by using the
    /// `arrivalDepartures` setter instead.
    public var arrivalDeparture: ArrivalDeparture! {
        didSet {
            if deemphasizePastEvents {
                // 'Gray out' the view if it occurred in the past.
                alpha = arrivalDeparture.temporalState == .past ? 0.50 : 1.0
            }

            routeHeadsignLabel.text = title ?? arrivalDeparture.routeAndHeadsign

            configureExplanationText()

            topMinutesLabel.text = formatters.shortFormattedTime(until: arrivalDeparture)
            topMinutesLabel.textColor = formatters.colorForScheduleStatus(arrivalDeparture.scheduleStatus)

            minutesStack.insertArrangedSubview(topMinutesWrapper, at: 0)
        }
    }

    private func configureExplanationText() {
        let arrDepTime = formatters.timeFormatter.string(from: arrivalDeparture.arrivalDepartureDate)

        let explanationText: String
        if arrivalDeparture.scheduleStatus == .unknown {
            explanationText = Strings.scheduledNotRealTime
        }
        else {
            explanationText = formatters.formattedScheduleDeviation(for: arrivalDeparture)
        }

        let scheduleStatusColor = formatters.colorForScheduleStatus(arrivalDeparture.scheduleStatus)

        let timeExplanationFont = UIFont.preferredFont(forTextStyle: .footnote)

        let attributedExplanation = NSMutableAttributedString(string: "\(arrDepTime) - ", attributes: [NSAttributedString.Key.font: timeExplanationFont])

        let explanation = NSAttributedString(string: explanationText, attributes: [NSAttributedString.Key.font: timeExplanationFont, NSAttributedString.Key.foregroundColor: scheduleStatusColor])
        attributedExplanation.append(explanation)

        timeExplanationLabel.attributedText = attributedExplanation
    }

    /// Alternative to `arrivalDeparture`. Set this to display up to three `ArrivalDeparture`s in this view.
    public var arrivalDepartures: [ArrivalDeparture]? {
        didSet {
            guard let arrivalDepartures = arrivalDepartures else { return }

            minutesStack.addArrangedSubview(minutesSpacer)

            if let first = arrivalDepartures.first {
                arrivalDeparture = first
            }

            let updateLabelWithDeparture = { (label: UILabel, wrapper: UIView, index: Int) in
                if arrivalDepartures.count > index {
                    let dep = arrivalDepartures[index]
                    label.text = self.formatters.shortFormattedTime(until: dep)
                    label.textColor = self.formatters.colorForScheduleStatus(dep.scheduleStatus)
                    self.minutesStack.insertArrangedSubview(wrapper, at: index)
                }
                else {
                    wrapper.removeFromSuperview()
                    label.text = nil
                }
            }

            updateLabelWithDeparture(topMinutesLabel, topMinutesWrapper, 0)
            updateLabelWithDeparture(centerMinutesLabel, centerMinutesWrapper, 1)
            updateLabelWithDeparture(bottomMinutesLabel, bottomMinutesWrapper, 2)
        }
    }

    private lazy var leftStack: UIStackView = UIStackView.verticalStack(arangedSubviews: [routeHeadsignLabel, timeExplanationLabel, UIView.autolayoutNew()])

    private lazy var leftStackWrapper: UIView = {
        return leftStack.embedInWrapperView()
    }()

    private lazy var outerStackView: UIStackView = {
        let outerStack = UIStackView.horizontalStack(arrangedSubviews: [leftStackWrapper, minutesWrappers])
        outerStack.spacing = ThemeMetrics.padding
        return outerStack
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(outerStackView)
        outerStackView.pinToSuperview(.layoutMargins)

        if kUseDebugColors {
            routeHeadsignLabel.backgroundColor = .red
            timeExplanationLabel.backgroundColor = .orange
            disclosureIndicator.backgroundColor = .blue
            topMinutesLabel.backgroundColor = .purple
            topMinutesWrapper.backgroundColor = .green
            minutesWrappers.backgroundColor = .brown
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Highlightable

    public func setIsHighlighted(_ isHighlighted: Bool) {
      guard let cell = superview as? StackViewCell else { return }
        cell.backgroundColor = isHighlighted ? ThemeColors.shared.highlightedBackgroundColor : cell.rowBackgroundColor
    }

    // MARK: - Tappable

    public func didTapView() {
        delegate?.stopArrivalTapped(arrivalDeparture: arrivalDeparture)
    }

    // MARK: - UI Builders

    private class func buildMinutesLabel() -> HighlightChangeLabel {
        let label = HighlightChangeLabel.autolayoutNew()
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)

        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)

        return label
    }

    private class func buildLabel() -> UILabel {
        let label = UILabel.autolayoutNew()
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.defaultLow, for: .vertical)

        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)

        return label
    }

    private func buildMinutesLabelWrapper(label: UILabel) -> UIView {
        let wrapper = label.embedInWrapperView()
        wrapper.setContentCompressionResistancePriority(.required, for: .vertical)
        wrapper.setContentCompressionResistancePriority(.required, for: .horizontal)
        return wrapper
    }
}
